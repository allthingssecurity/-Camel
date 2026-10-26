# Message.getBody(Object.class) on a null body returns the Message itself

Status: code-bug candidate (L0 type-conversion differential, theories/L0/Convert.v). Camel aa63c0a4cb94.
Severity guess: low to medium (anything that reads the body as `Object` through `getBody(Class)` gets a
`DefaultMessage` instead of null when there is no body, e.g. `${bodyAs(java.lang.Object)}`).

## Rule and doc lines

- `L0.TC.api_getBody` DOC: `getBody(type)` "@return the body of the message as the specified type, or null if body
  does not exist" (docs/core/camel-api/src/main/java/org/apache/camel/Message.java lines 296-297); @Metadata line
  305: "null when there is no body or no conversion".

## Real Camel

    msg.setBody(null); msg.getBody(Object.class)               -> org.apache.camel.support.DefaultMessage ("Message")
    simple "${bodyAs(java.lang.Object)}" on a null body        -> the DefaultMessage
    msg.getMandatoryBody(Object.class) on a null body          -> InvalidPayloadException (as documented)
    msg.getBody(String.class) / getBody(Integer.class), null body -> null (as documented)

Differential: 1 case (getBody java.lang.Object N).

## Cause

`MessageSupport.getBody(Class, Object)`: when converting the body gives null, it falls back to converting the
message itself ("fallback and try the message itself (e.g. used in camel-http)", `typeConverter.tryConvertTo(type,
e, this)`). For `Object.class` every value converts, so the Message is returned for a null body. The fallback is
deliberate for types a Message converts to (camel-http); returning the Message as "the body" for `Object` is
presumably not. The history of this method before 025f7cb97232 (root of the local clone) is not available.

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
Exchange e = new DefaultExchange(c);
e.getIn().setBody(null);
assertNull(e.getIn().getBody(Object.class));   // fails: returns the DefaultMessage
```

## Possible fix (for the pipeline to judge)

Skip the message fallback when the body is null and `type` is `Object.class` (or when the type is assignable from
Message and the body is null), and check camel-http's use of the fallback.
