/*
********************************************************************************
CIS276 @PCC using SQL Server 2012
2022.11.26 Noelle Landauer
Lab 8
********************************************************************************
*/
USE s276_NoelleL

/*
--------------------------------------------------------------------------------
ValidateCustID - CUSTOMERS.CustID validation
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateCustID')
    BEGIN 
        DROP PROCEDURE ValidateCustID; 
    END;   
-- END IF;  SQL Server does not use END IF 
GO


CREATE PROCEDURE ValidateCustID 
    @vCustid SMALLINT,
	@vFound CHAR(10) OUTPUT 
AS 

BEGIN 
    SET @vFound = 'blank';  
    SELECT @vFound = Cname 
    FROM CUSTOMERS
    WHERE CustID = @vCustid;

	IF @@ROWCOUNT = 0
		PRINT 'Customer ID ' + LTRIM(STR(@vCustid)) + ' does not exist';
	--ENDIF
END;
GO

-- testing block for ValidateCustID
BEGIN
    
    DECLARE @vCname CHAR(25);  

    EXECUTE ValidateCustID 1, @vCname OUTPUT;
    PRINT 'ValidateCustID test with valid CustID 1 returns ' + @vCname;
	

    EXECUTE ValidateCustID 5, @vCname OUTPUT;
    PRINT 'ValidateCustID test w/invalid CustID 5 returns ' + @vCname;
	

END;
GO

/*
--------------------------------------------------------------------------------
ValidateOrderID - ORDERS.OrderID validation
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateOrderID')
    BEGIN DROP PROCEDURE ValidateOrderID; END;
--ENDIF
GO

CREATE PROCEDURE ValidateOrderID -- with custid and orderid input
@vCustid SMALLINT,
@vOrderid SMALLINT,
@vOrdFound CHAR(20) OUTPUT,
@vMatch CHAR(10) OUTPUT

AS 
BEGIN 
-- OrderID found in ORDERS table . . .
	SET @vOrdFound = 'order_not_found';
	SELECT @vOrdFound = 'order_found'
	FROM ORDERS
	WHERE @vOrderid = OrderID;

	IF @@ROWCOUNT = 0
		BEGIN
		SET @vOrdFound = 'blank'
		END;
	--ENDIF

--Custid : Orderid matching
	BEGIN
		SET @vMatch = 'mismatch'
		SELECT @vMatch = 'match'
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
	DECLARE @retMsg CHAR(20);
	DECLARE @retMatch CHAR(10);

--Valid Orderid, Custid matches
	EXECUTE ValidateOrderID 1, 6099, @retMsg OUTPUT, @retMatch OUTPUT;
	PRINT 'ValidateOrderID test with valid Order ID & matching Custid returns' + @retMsg + @retMatch;

-- Valid Orderid, Custid does not match
	EXECUTE ValidateOrderID 1, 6128, @retMsg OUTPUT, @retMatch OUTPUT;
	PRINT 'ValidateOrderID test with valid Order ID, mismatched Custid returns ' + @retMsg + @retMatch;

--Invalid Orderid, custid must mismatch
	EXECUTE ValidateOrderID 1, 6090, @retMsg OUTPUT, @retMatch OUTPUT;
	PRINT 'ValidateOrderID test with invalid Order ID returns ' + @retMsg + @retMatch;

END;
GO

/*
--------------------------------------------------------------------------------
ValidatePartID - INVENTORY.PartID validation
Noelle Landauer, 11/29/22
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
	--ENDIF
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

/*
--------------------------------------------------------------------------------
Procedure ValidateQty - Input order quantity validation
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateQty')
    BEGIN DROP PROCEDURE ValidateQty; END;
GO

CREATE PROCEDURE ValidateQty 
@vOrderQty SMALLINT,
@vQtyMarker CHAR(10) OUTPUT

AS 
BEGIN 
	IF @vOrderQty <= 0
		BEGIN
		PRINT 'Order quantity must be greater than zero'
		SET @vQtyMarker = 'invalid'
		END;
	ELSE 
		SET @vQtyMarker = 'valid';
	--ENDIF
END;
GO

--testing block for ValidateQty
BEGIN    
	DECLARE @retQtyMarker CHAR(10);

--Valid Qty
	EXECUTE ValidateQty 5, @retQtyMarker OUTPUT;
	PRINT 'ValidateQty test with valid (positive) qty, returns ' + @retQtyMarker;

-- Invalid Qty = 0
	EXECUTE ValidateQty 0, @retQtyMarker OUTPUT;
	PRINT 'ValidateQty test with invalid (zero) qty, returns ' + @retQtyMarker;

--Invalid Qty = negative
	EXECUTE ValidateQty -1, @retQtyMarker OUTPUT;
	PRINT 'ValidateQty test with invalid (negative) qty, returns ' + @retQtyMarker;

END;
GO

/*
--------------------------------------------------------------------------------
Procedure GetNewDetail - ORDERITEMS.Detail determines new value
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'GetNewDetail')
    BEGIN DROP PROCEDURE GetNewDetail; END;
GO

CREATE PROCEDURE GetNewDetail
@vOrderid SMALLINT,
@vDetail SMALLINT OUTPUT

AS 
BEGIN 

	SELECT @vDetail = ISNULL(MAX(Detail), 0)
	FROM ORDERITEMS
	WHERE @vOrderid = OrderID;

	SET @vDetail = @vDetail + 1;

END;
GO

-- testing block for GetNewDetail
BEGIN 
	
	DECLARE @retDetail SMALLINT;

-- Existing Order ID with existing detail
	EXECUTE GetNewDetail 6099, @retDetail OUTPUT;
	PRINT 'GetNewDetail test, with valid order ID, returns ' + LTRIM(STR(@retDetail));

-- Insert new order without existing detail. Output = 1
	INSERT INTO ORDERS VALUES(6240, 103, 12, GETDATE());
	EXECUTE GetNewDetail 6240, @retDetail OUTPUT;
	PRINT 'GetNewDetail test, with valid order ID, returns ' + LTRIM(STR(@retDetail));
	DELETE FROM ORDERS WHERE OrderID = 6240;

END;
GO

/*
--------------------------------------------------------------------------------
Trigger InventoryUpdateTRG - INVENTORY trigger for an UPDATE
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'InventoryUpdateTRG')
    BEGIN DROP TRIGGER InventoryUpdateTRG; END;
GO

CREATE TRIGGER InventoryUpdateTRG
ON INVENTORY
FOR UPDATE
AS
	DECLARE @vStockQty SMALLINT;
	DECLARE @vErrMsg CHAR(80);
BEGIN
	SELECT @vStockQty = StockQty FROM INSERTED;

	IF @vStockQty < 0
		BEGIN
			SET @vErrMsg = 'Error in InventoryUpdateTRG: Inadequate Stock Qty';
			RAISERROR(@vErrMsg, 2, 2) WITH SETERROR;
		END;
	--ENDIF		
END;
GO

-- testing blocks for InventoryUpdateTRG
BEGIN
-- StockQty = 0 (pass)
	UPDATE INVENTORY SET StockQty = 0 WHERE PartID = 1005;
	BEGIN TRANSACTION
	IF @@ERROR <> 0
		BEGIN
		PRINT 'Error in InventoryUpdateTRG';
		ROLLBACK TRANSACTION;
		END;
	ELSE 
		BEGIN
		PRINT 'Success InventoryUpdateTRG';
		COMMIT TRANSACTION;
		END;

-- StockQty negative (fail)
	UPDATE INVENTORY SET StockQty = -5 WHERE PartID = 1005;
	BEGIN TRANSACTION
	IF @@ERROR <> 0
		BEGIN
		PRINT 'Error in InventoryUpdateTRG';
		ROLLBACK TRANSACTION;
		END;
	ELSE 
		BEGIN
		PRINT 'Success InventoryUpdateTRG';
		COMMIT TRANSACTION;
		END;

-- StockQty positive (pass)
	UPDATE INVENTORY SET StockQty = 5 WHERE PartID = 1005;
	BEGIN TRANSACTION
	IF @@ERROR <> 0
		BEGIN
		PRINT 'Error in InventoryUpdateTRG';
		ROLLBACK TRANSACTION;
		END;
	ELSE 
		BEGIN
		PRINT 'Success InventoryUpdateTRG';
		COMMIT TRANSACTION;
		END;
	
END;
GO

/*
--------------------------------------------------------------------------------
Trigger OrderitemsInsertTRG - ORDERITEMS trigger for an INSERT
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'OrderitemsInsertTRG')
    BEGIN DROP TRIGGER OrderitemsInsertTRG; END;
GO

CREATE TRIGGER OrderitemsInsertTRG
ON ORDERITEMS
FOR INSERT
AS
BEGIN 
	DECLARE @vOrderQty SMALLINT;
	DECLARE @vPartid SMALLINT;
	DECLARE @vOldStockQty SMALLINT;
	DECLARE @vErrMsg CHAR(225);

	SELECT @vOrderQty = Qty, @vPartid = PartID FROM INSERTED;
	SELECT @vOldStockQty = StockQty FROM INVENTORY WHERE @vPartid = PartID;

	UPDATE INVENTORY 
	SET StockQty = @vOldStockQty - @vOrderQty
	WHERE @vPartid = PartID;

	IF (@@ERROR <> 0) 
        BEGIN 
			SET @vErrMsg = 'Error in OrderItemsTRG, Update in ORDERITEMS table failed.';
			RAISERROR (@vErrMsg, 1, 2) WITH SetError;
		END;

END;
GO

-- testing blocks for OrderItemsInsertTrg
BEGIN
-- Valid OrderID, PartID, adequate resulting StockQty (Pass)
	SELECT StockQty FROM INVENTORY WHERE PartID = 1002;
	INSERT INTO ORDERITEMS
	VALUES (6215, 11, 1002, 10);
	SELECT StockQty FROM INVENTORY WHERE PartID = 1002;

-- Valid OrderID, PartID, resulting StockQty = 0 (Pass)
	SELECT StockQty FROM INVENTORY WHERE PartID = 1004;
	INSERT INTO ORDERITEMS
	VALUES (6216, 8, 1004, 71);
	SELECT StockQty FROM INVENTORY WHERE PartID = 1004;

--Valid OrderID, PartID, resulting StockQty < 0 (Fail)
	SELECT StockQty FROM INVENTORY WHERE PartID = 1006;
	INSERT INTO ORDERITEMS
	VALUES (6217, 9, 1006, 200);
	SELECT StockQty FROM INVENTORY WHERE PartID = 1006;

END;
GO

/* 
--------------------------------------------------------------------------------
Procedure AddLineItem - Inserts orderid, detail, partid, qty into ORDERITEMS
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'AddLineItem')
    BEGIN DROP PROCEDURE AddLineItem; END;
GO

CREATE PROCEDURE AddLineItem
@iOrderid SMALLINT, 
@iPartid SMALLINT,
@iOrderQty SMALLINT

AS

DECLARE @vDetail SMALLINT;
DECLARE @vErrMsg CHAR(225);

BEGIN
BEGIN TRANSACTION   
    EXECUTE GetNewDetail @iOrderid, @vDetail OUTPUT;
	INSERT INTO ORDERITEMS VALUES (@iOrderid, @vDetail, @iPartid, @iOrderQty);
	IF @@ERROR <> 0
		BEGIN
		PRINT 'Error from AddLineItem, insert failed';
		ROLLBACK TRANSACTION;
		END;
	ELSE
		BEGIN
		PRINT 'Insert was successful';
		COMMIT;
		END;
	--ENDIF

-- END TRANSACTION;
END;
GO

BEGIN
	EXECUTE AddLineItem 6099,1001,10;
	SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
END;
GO

/* 
--------------------------------------------------------------------------------
Lab8proc - Executing procedure
Noelle Landauer, 11/29/22
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'Lab8proc')
    BEGIN 
	DROP PROCEDURE Lab8proc; 
	END;
GO

CREATE PROCEDURE Lab8proc
@iCustid SMALLINT, 
@iOrderid SMALLINT, 
@iPartid SMALLINT, 
@iOrderQty SMALLINT

AS
	DECLARE @vReturnMsg CHAR(20);
	DECLARE @vMatch CHAR(10);

BEGIN

	EXECUTE ValidateCustID @iCustid, @vReturnMsg OUTPUT;
	IF @vReturnMsg = 'blank'
		BEGIN
		PRINT 'Invalid Customer ID' + LTRIM(STR(@iCustid));
		PRINT 'FAILURE';
		RETURN;
		END;
	ELSE 
		PRINT 'Customer ID is OK - continue';
	--ENDIF

	EXECUTE ValidateOrderID @iCustid, @iOrderid, @vReturnMsg OUTPUT, @vMatch OUTPUT;
	IF @vReturnMsg = 'order_not_found'
		BEGIN
		PRINT 'Invalid Order ID ' + LTRIM(STR(@iOrderid));
		PRINT 'FAILURE';
		RETURN;
		END;
	ELSE
		IF @vMatch = 'mismatch'
			BEGIN
			PRINT 'FAILURE';
			RETURN;
			END;
		ELSE 
			PRINT 'Order ID is OK and Customer ID matches - continue';
		--ENDIF
	--ENDIF

	EXECUTE ValidatePartID @iPartid, @vReturnMsg OUTPUT;
	IF @vReturnMsg = 'blank'
		BEGIN
		PRINT 'Invalid Part ID ' + LTRIM(STR(@iPartid));
		PRINT 'FAILURE';
		RETURN;
		END;
	ELSE
		PRINT 'Part ID is OK - continue';

	EXECUTE ValidateQty @iOrderQty, @vReturnMsg OUTPUT;
	IF @vReturnMsg = 'invalid'
		BEGIN
		PRINT 'Invalid order quantity; must be greater than zero';
		PRINT 'FAILURE';
		RETURN;
		END;
	ELSE 
		PRINT 'Valid order quantity - continue';

	IF @@ERROR <> 0
		PRINT 'Error in Lab9proc: Unable to insert new line item for orderID ' + LTRIM(STR(@iOrderid));
	ELSE
		BEGIN
		EXECUTE AddLineItem @iOrderid, @iPartid, @iOrderQty;
		PRINT 'AddLineItem succesfully executed';
		END;
	-- ENDIF;
END;
GO 

/*
--------------------------------------------------------------------------------
-- Testing blocks for Lab8proc
--------------------------------------------------------------------------------
*/



BEGIN
--Invalid Custid, Valid Orderid, Partid, Qty (FAIL)
EXECUTE Lab8proc 5, 6099, 1001, 15;

 --CustID & Partid exist, OrderID does not exist; FAIL
EXECUTE Lab8proc 1, 6090, 1001, 15;

-- CustID, OrderID, Partid all exist, but OrderID belong to different CustID; FAIL
EXECUTE Lab8proc 2, 6099, 1001, 15;

-- PartID does not exist, CustID & OrderID are valid; FAIL
EXECUTE Lab8proc 1, 6099, 1000, 15;

-- Quantity entered is less than 0; FAIL
EXECUTE Lab8proc 1, 6099, 1001, -1;

-- Quantity entered = 0; FAIL
EXECUTE Lab8proc 1, 6099, 1001, 0;

-- Stock Qty is less than 0 after transaction; FAIL
SELECT * FROM INVENTORY WHERE PartID = 1003;
EXECUTE Lab8proc 1, 6099, 1003, 30 ;
SELECT * FROM INVENTORY WHERE PartID = 1003;

-- Stock Qty = 0 after transaction; SUCCESS
SELECT * FROM INVENTORY WHERE PartID = 1007;
EXECUTE Lab8proc 1, 6099, 1007, 10;
SELECT * FROM INVENTORY WHERE PartID = 1007;

-- Order exists but has no orderitems; SUCCESS (DETAIL = 1)
SELECT * FROM ORDERITEMS WHERE OrderID = 6140;
INSERT INTO ORDERS
VALUES(6140, 103, 12, GETDATE());
EXECUTE Lab8proc 12, 6140, 1001, 5;
SELECT * FROM ORDERITEMS WHERE OrderID = 6140;

-- Everything valid
SELECT * FROM ORDERITEMS WHERE OrderID = 6155;
EXECUTE Lab8proc 12, 6155, 1001, 15;
SELECT * FROM ORDERITEMS WHERE OrderID = 6155;

END;
