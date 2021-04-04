function Convert-DateTimeToGPPExpirationDate {
    [OutputType('string')]
    Param (
        [datetime]$DateTime
    )

    '{0:yyyy}-{0:MM}-{0:dd}' -f $DateTime
}