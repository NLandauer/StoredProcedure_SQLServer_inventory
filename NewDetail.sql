USE s276_NoelleL

/*
--------------------------------------------------------------------------------
ORDERITEMS.Detail determines new value:
You can handle NULL within the projection but it can be done in two steps
(SELECT and then test).  It is important to deal with the possibility of NULL
because the detail is part of the primary key and therefore cannot contain NULL.
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

