# getMandatoryBody(int.class) (and long/double/boolean) on a null body returns 0 / false

Status: code-bug candidate (L0 type-conversion differential, theories/L0/Convert.v). Camel aa63c0a4cb94.
Severity guess: low (backlog; a mandatory read of a missing body silently gives 0 or false).

## Rule and doc lines

- `L0.TC.api_getMandatoryBody` DOC: "@return the body of the message as the specified type, is never null.
  @throws InvalidPayloadException Is thrown if the body being null or wrong class type"
  (docs/core/camel-api/src/main/java/org/apache/camel/Message.java lines 321-322; @Metadata lines 327-328 "throws
  InvalidPayloadException when the body is null or cannot be converted").
- simple-functions.adoc line 116: "`${mandatoryBodyAs(Integer)}` will throw an exception if the body is `null`".

## Real Camel

    msg.setBody(null); msg.getMandatoryBody(int.class)      -> Integer 0
    getMandatoryBody(long.class) -> Long 0, (double.class) -> Double 0.0, (boolean.class) -> false
    simple "${mandatoryBodyAs(int)}" on a null body          -> 0
    msg.getMandatoryBody(Integer.class) / mandatoryBodyAs(Integer) on a null body -> InvalidPayloadException / exception

Differential: 4 cases (getMandatoryBody int/long/double/boolean N).

## Cause

`MessageSupport.getMandatoryBody(Class)` has no null check of its own; it calls
`typeConverter.mandatoryConvertTo(type, e, getBody())`, and the converter gives the primitive zero for a null value
(documented for the converter in camel-4x-upgrade-guide-4_24.adoc line 2458: "Camel's type converter returns `0` or
`false` for a null value that is converted to a primitive type"). `getMandatoryBody()` (no type) does check for null.
No test found that pins the zero for getMandatoryBody; the history before 025f7cb97232 (root of the local clone) is
not available.

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
Exchange e = new DefaultExchange(c);
assertThrows(InvalidPayloadException.class, () -> e.getIn().getMandatoryBody(int.class)); // fails: returns 0
```

## Possible fix (for the pipeline to judge)

Throw `InvalidPayloadException` in `getMandatoryBody(Class)` when the body is null, as `getMandatoryBody()` does.
