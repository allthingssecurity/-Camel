# mandatoryConvertTo / getMandatoryBody / convertBodyTo to BigDecimal or BigInteger return null for a non-number

Status: code-bug candidate (from the L0 type-conversion differential, theories/L0/Convert.v). Camel aa63c0a4cb94.
Severity guess: medium (silent data loss: `convertBodyTo(BigDecimal.class)`, whose `mandatory` option defaults to
true, replaces a Boolean, List, Date, ... body with null and the route carries on).

## Rule and doc lines

- `L0.TC.api_mandatoryConvertTo` DOC: `mandatoryConvertTo` "@return the converted value, is never null",
  "@throws NoTypeConversionAvailableException if no type converters exists to convert to the given type"
  (docs/core/camel-api/src/main/java/org/apache/camel/TypeConverter.java lines 92-94; @Metadata line 97 "throws
  NoTypeConversionAvailableException when there is no conversion").
- `L0.TC.api_getMandatoryBody` DOC: `getMandatoryBody(type)` "is never null", "throws InvalidPayloadException when
  the body is null or cannot be converted" (Message.java lines 321-322, 327-328).
- convertBodyTo option `mandatory` (default true): "If mandatory and conversion is not possible, a
  NoTypeConversionAvailableException is thrown" (camel-core-model .../model/convertBodyTo.json line 20, rendered on
  convertBodyTo-eip.adoc via the eip-options partial).

## Real Camel

    tc.mandatoryConvertTo(BigDecimal.class, Boolean.TRUE)      -> null
    tc.mandatoryConvertTo(BigInteger.class, Boolean.TRUE)      -> null
    tc.mandatoryConvertTo(BigDecimal.class, new Object())      -> null
    tc.mandatoryConvertTo(Integer.class, Boolean.TRUE)         -> NoTypeConversionAvailableException (as documented)
    msg.setBody(Boolean.TRUE); msg.getMandatoryBody(BigDecimal.class) -> null
    from("direct:bd").convertBodyTo(BigDecimal.class); requestBody("direct:bd", true) -> null body, no exception
    simple "${mandatoryBodyAs(java.math.BigDecimal)}" on body true -> null

Differential: 14 cases (mandatoryConvertTo and getMandatoryBody x {Boolean true/false, List of 0/1/2 Strings}).

## Cause

`ObjectConverter.toBigDecimal(Object)` (new in a24e8e2e8e9b, CAMEL-25366, 2026-10-06) and `toBigInteger(Object)`
(older; the same pattern) are `@Converter(allowNull = true)` and end with `else { return null; }` for any value that
is neither a String nor a Number. With `allowNull`, the bulk loader turns that null into the `Void.class` sentinel
and `CoreTypeConverterRegistry.mandatoryConvertTo` returns null for it ("a positive answer", as
camel-4x-upgrade-guide-4_12.adoc lines 52-53 describe for allowNull converters). The javadoc of both methods says
"Returns the converted value, or null if the value is null", so the null for a non-number is not the documented
intent of the converter; the allowNull flag is there for the NaN case (`isNaN(value) -> null`).

Git: a24e8e2e8e9b's ObjectConverterTest pins `assertNull(ObjectConverter.toBigDecimal(new Date()))` at the method
level only; no test pins what `mandatoryConvertTo` / `convertBodyTo` give. The history of `toBigInteger` before
025f7cb97232 (root of the local clone) is not available.

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
assertThrows(NoTypeConversionAvailableException.class,
    () -> c.getTypeConverter().mandatoryConvertTo(BigDecimal.class, Boolean.TRUE)); // fails: returns null
```

Probe source: build/harness-convert cases `mandatoryConvertTo java.math.BigDecimal B1` etc. (harness/convert/run.sh).

## Possible fix (for the pipeline to judge)

Give a miss (not null) for a value that is neither String nor Number in `toBigDecimal` / `toBigInteger`, keeping
null only for NaN; or drop `allowNull` and map NaN separately. Check `toBigInteger` users before changing it.
