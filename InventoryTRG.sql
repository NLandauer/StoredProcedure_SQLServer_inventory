USE s276_NoelleL

/*
--------------------------------------------------------------------------------
INVENTORY trigger for an UPDATE:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'InventoryUpdateTRG')
    BEGIN DROP TRIGGER InventoryUpdateTRG; END;
GO

CREATE TRIGGER InventoryUpdateTRG
ON INVENTORY
FOR UPDATE
AS
BEGIN 
	DECLARE @vStockQty SMALLINT;
	DECLARE @vErrMsg CHAR(50);

	SELECT @vStockQty = StockQty FROM INSERTED;

	IF @vStockQty < 0
		BEGIN
			SET @vErrMsg = 'Error in InventoryUpdateTRG: Inadequate Stock Qty';
			RAISERROR (@vErrMsg, 1, 2) WITH SetError;
		END;
	--ENDIF		
END;
GO

-- testing blocks for InventoryUpdateTRG
BEGIN
-- StockQty = 0 (pass)
	UPDATE INVENTORY SET StockQty = 0 WHERE PartID = 1005;

-- StockQty negative (fail)
	UPDATE INVENTORY SET StockQty = -5 WHERE PartID = 1005;

-- StockQty positive (pass)
	UPDATE INVENTORY SET StockQty = 5 WHERE PartID = 1005;
	
END;
GO

