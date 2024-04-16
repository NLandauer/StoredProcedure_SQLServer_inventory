USE s276_NoelleL
/*
--------------------------------------------------------------------------------
INVENTORY.PartID validation:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidatePartID')
    BEGIN DROP PROCEDURE ValidatePartID; END;
GO

CREATE PROCEDURE ValidatePartID 
@vPartid SMALLINT,
@vPartFound CHAR(10) OUTPUT

AS 
BEGIN 
	SET @vPartFound = 'blank';
	SELECT @vPartFound = PartID
	FROM INVENTORY
	WHERE @vPartid = PartID;

	IF @@ROWCOUNT = 0
		PRINT 'Part ID ' + LTRIM(STR(@vPartid)) + ' does not exist.';
END;
GO

-- testing block for ValidatePartID
BEGIN    
	DECLARE @retPartid CHAR(10);

	-- Valid Partid
	EXECUTE ValidatePartID 1001, @retPartid OUTPUT;
	PRINT 'ValidatePartID test with valid Part ID, returns ' + @retPartid;

	--Invalid Partid
	EXECUTE ValidatePartID 1000, @retPartid OUTPUT;
	PRINT 'ValidatePartID test with invalid Part ID, returns ' + @retPartid;

END;
GO