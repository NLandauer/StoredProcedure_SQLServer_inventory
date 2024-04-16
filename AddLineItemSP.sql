USE s276_NoelleL
/* 
--------------------------------------------------------------------------------
The TRANSACTION, this procedure calls GetNewDetail and performs an INSERT
to the ORDERITEMS table which in turn performs an UPDATE to the INVENTORY table.
Error handling determines COMMIT/ROLLBACK.
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

DECLARE @vErrMsg CHAR(225);
DECLARE @vDetail SMALLINT;

BEGIN
BEGIN TRANSACTION    -- this is the only BEGIN TRANSACTION for the lab assignment
    EXECUTE GetNewDetail @iOrderid, @vDetail OUTPUT;
	INSERT INTO ORDERITEMS VALUES (@iOrderid, @vDetail, @iPartid, @iOrderQty);
	IF (@@ERROR <> 0 OR @@ROWCOUNT = 0)
		BEGIN
		PRINT 'Error in AddLineItemSP, unable to insert into ' + @iOrderid;
		ROLLBACK TRANSACTION;
		END;
	ELSE
		BEGIN
		PRINT 'Insert into Order ID ' + LTRIM(STR(@iOrderid)) + ' was successful';
		COMMIT;
		END;
	--ENDIF

-- END TRANSACTION;
END;
GO

BEGIN
	EXECUTE AddLineItem 6099,1001,50;
	SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
END;
GO



