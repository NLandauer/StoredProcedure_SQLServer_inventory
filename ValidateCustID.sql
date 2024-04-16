USE s276_NoelleL

/*
--------------------------------------------------------------------------------
CUSTOMERS.CustID validation
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateCustID')
    BEGIN 
        DROP PROCEDURE ValidateCustID; 
    END;    -- must use block for more than one statement
-- END IF;  SQL Server does not use END IF 
GO

-- Notice my found variable contains the customer name
-- YOU can/should do something else to indicate a row exists to validate CustID

CREATE PROCEDURE ValidateCustID 
    @vCustid SMALLINT,
    @vFound  CHAR(25) OUTPUT 
AS 
BEGIN 
    SET @vFound = 'blank';  -- initializes my found variable
    SELECT @vFound = Cname 
    FROM CUSTOMERS
    WHERE CustID = @vCustid;

	IF @@ROWCOUNT = 0
		PRINT 'Customer ID ' + LTRIM(STR(@vCustid)) + ' does not exist';
END;
GO

-- testing block for ValidateCustID
BEGIN
    
    DECLARE @vCname CHAR(25);  -- holds value returned from procedure

    EXECUTE ValidateCustID 1, @vCname OUTPUT;
    PRINT 'ValidateCustID test with valid CustID 1 returns ' + @vCname;
	-- When @vCname contains a customer name the custid is validated

    EXECUTE ValidateCustID 5, @vCname OUTPUT;
    PRINT 'ValidateCustID test w/invalid CustID 5 returns ' + @vCname;
	-- When @vCname contains 'blank' the custid is not in the CUSTOMERS table

END;
GO