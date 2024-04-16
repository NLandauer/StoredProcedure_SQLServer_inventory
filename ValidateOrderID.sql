USE s276_NoelleL

/*
--------------------------------------------------------------------------------
ORDERS.OrderID validation:
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateOrderID')
    BEGIN DROP PROCEDURE ValidateOrderID; END;
GO

CREATE PROCEDURE ValidateOrderID -- with custid and orderid input
@vCustid SMALLINT,
@vOrderid SMALLINT,
@vOrdFound CHAR(10) OUTPUT,
@vMatch CHAR(10) OUTPUT

AS 
BEGIN 
-- OrderID found in ORDERS table . . .
	SET @vOrdFound = 'blank';
	SELECT @vOrdFound = OrderID
	FROM ORDERS
	WHERE @vOrderid = OrderID;

	IF @@ROWCOUNT = 0
		PRINT 'OrderID ' + LTRIM(STR(@vOrderid)) + ' not found'

--Custid : Orderid matching
	BEGIN
		SET @vMatch = 'mismatch'
		SELECT @vMatch = CustID
		FROM ORDERS
		WHERE @vCustid = CustID
		AND @vOrderid = OrderID;

		IF @@ROWCOUNT = 0
			PRINT 'Customer - Order mismatch';
	END;
END;
GO

-- testing block for ValidateOrderID
BEGIN  
	DECLARE @retOrder CHAR(10);
	DECLARE @retMatch CHAR(10);

--Valid Orderid, Custid matches
	EXECUTE ValidateOrderID 1, 6099, @retOrder OUTPUT, @retMatch OUTPUT;
	PRINT 'ValidateOrderID test with valid Order ID & matching Custid returns Order =' + @retOrder +
	'Custid =' + @retMatch;

-- Valid Orderid, Custid does not match
	EXECUTE ValidateOrderID 1, 6128, @retOrder OUTPUT, @retMatch OUTPUT;
	PRINT 'ValidateOrderID test with valid Order ID, mismatched Custid returns Order =' + @retOrder +
	'Custid =' + @retMatch;

--Invalid Orderid, custid must mismatch
	EXECUTE ValidateOrderID 1, 6090, @retOrder OUTPUT, @retMatch OUTPUT;
	PRINT 'ValidateOrderID test with invalid Order ID returns Order =' + @retOrder +
	'Custid=' + @retMatch;

END;
GO