fn fit value sourceMin sourceMax targetMin targetMax =
(
    local percentage = (value - sourceMin) / (sourceMax - sourceMin)

    local mappedValue = targetMin + (percentage * (targetMax - targetMin))

    return mappedValue
)