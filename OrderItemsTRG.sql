USE s276_NoelleL
/*
--------------------------------------------------------------------------------
ORDERITEMS trigger for an INSERT:
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
	DECLARE @vErrMsg CHAR(25);

	SELECT @vOrderQty = Qty, @vPartid = PartID FROM INSERTED;
	SELECT @vOldStockQty = StockQty FROM INVENTORY WHERE @vPartid = PartID;

	UPDATE INVENTORY 
	SET StockQty = @vOldStockQty - @vOrderQty
	WHERE @vPartid = PartID;

	IF (@@ERROR <> 0) 
        BEGIN 
			SET @vErrMsg = 'Error in OrderItemsTRG, Update in ORDERITEMS table failed.'
			RaisError(@vErrMsg,1,2) WITH SetError;
		END;

    -- get new values for qty and partid from the INSERTED table
    -- get current (changed) StockQty for this PartID
    -- UPDATE with current (changed) StockQty 
    -- your error handling
END;
GO

-- testing blocks for OrderItemsInsertTrg
BEGIN
-- Valid OrderID, PartID, adequate resulting StockQty
	SELECT StockQty FROM INVENTORY WHERE PartID = 1001;
	INSERT INTO ORDERITEMS
	VALUES (6099, 6, 1001, 10);
	SELECT StockQty FROM INVENTORY WHERE PartID = 1001;

--reset tables
	DELETE FROM ORDERITEMS WHERE OrderID = 6099 AND Detail = 6;
	UPDATE INVENTORY SET StockQty = 100 WHERE PartID = 1001;

-- Valid OrderID, PartID, resulting StockQty = 0
	SELECT StockQty FROM INVENTORY WHERE PartID = 1001;
	INSERT INTO ORDERITEMS
	VALUES (6099, 6, 1001, 100);
	SELECT StockQty FROM INVENTORY WHERE PartID = 1001;

--reset tables
	DELETE FROM ORDERITEMS WHERE OrderID = 6099 AND Detail = 6;
	UPDATE INVENTORY SET StockQty = 100 WHERE PartID = 1001;

--Valid OrderID, PartID, resulting StockQty < 0
	SELECT StockQty FROM INVENTORY WHERE PartID = 1001;
	INSERT INTO ORDERITEMS
	VALUES (6099, 6, 1001, 200);
	SELECT StockQty FROM INVENTORY WHERE PartID = 1001;

	DELETE FROM ORDERITEMS WHERE OrderID = 6099 AND Detail = 6;
	UPDATE INVENTORY SET StockQty = 100 WHERE PartID = 1001;

--Invalid OrderID
	INSERT INTO ORDERITEMS
	VALUES(6090, 6, 1001, 10);

END;
GO

SELECT * FROM ORDERITEMS WHERE OrderID = 6099;

