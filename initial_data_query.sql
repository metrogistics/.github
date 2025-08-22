-- Initial data fetching query from the original complex SQL
-- This query fetches the base data into #avs temporary table

DECLARE @StartDate DATE = '2024-01-01'
DECLARE @EndDate DATE = '2025-04-30'

SELECT t.*
    ,value AS BLNumber
INTO #avs
FROM API_VehiclCode_ScanLog t
CROSS APPLY STRING_SPLIT(IIF(t.Bl_Number = 0, coalesce((
                    SELECT TOP 1 cast(BL_Number AS VARCHAR)
                    FROM API_VehicleCode_AssignLog
                    WHERE Barcode = t.BL_Number
                        AND msg = 'Manual assignment'
                    ), (
                    SELECT TOP 1 BL_Number
                    FROM API_VehiclCode_ScanLog sl
                    WHERE sl.LogMessage = 'Barcode Details Fetched'
                        AND sl.id < t.Id
                        AND sl.Barcode = t.Barcode
                    ORDER BY id DESC
                    )), t.BL_Number), ',')
WHERE t.LogMessage = 'Battery Charge complete'
    AND (
        cast(t.Dateadded AS DATE) BETWEEN @StartDate
            AND @EndDate
        )
ORDER BY id;

CREATE INDEX idx_bl ON #avs (BLNUmber)

-- To view the initial data:
SELECT * FROM #avs;