IF (OBJECT_ID('cleanTaskInstance') IS NOT NULL)
  DROP PROCEDURE cleanTaskInstance
GO
IF (OBJECT_ID('TEMP_CLEANUP') IS NOT NULL)
  DROP TABLE TEMP_CLEANUP;
GO

DECLARE @ID INT;

-- 	Set ID to be removed
-- 	Ex:
--	SET @ID=11;

SET @ID = 0;
SELECT ID INTO TEMP_CLEANUP FROM HT_TASK WHERE STATUS ='COMPLETED' AND ID = @ID;
GO

CREATE PROCEDURE cleanTaskInstance
AS
BEGIN
	PRINT ' Start deleting task instance data with instance ids ';
	BEGIN TRANSACTION;
	DELETE FROM HT_DEADLINE WHERE TASK_ID IN (SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_EVENT WHERE HT_EVENT.TASK_ID IN (SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_ORG_ENTITY WHERE ORG_ENTITY_ID IN ( SELECT ORGENTITY_ID FROM HT_HUMANROLE_ORGENTITY WHERE HUMANROLE_ID IN ( SELECT GHR_ID FROM HT_GENERIC_HUMAN_ROLE WHERE TASK_ID IN ( SELECT ID FROM TEMP_CLEANUP)));
	DELETE FROM HT_HUMANROLE_ORGENTITY WHERE HUMANROLE_ID IN ( SELECT GHR_ID FROM HT_GENERIC_HUMAN_ROLE WHERE TASK_ID IN ( SELECT ID FROM TEMP_CLEANUP));
	DELETE FROM HT_GENERIC_HUMAN_ROLE WHERE TASK_ID IN(SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_PRESENTATION_ELEMENT WHERE TASK_ID IN (SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_PRESENTATION_PARAM WHERE TASK_ID IN (SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_MESSAGE WHERE TASK_ID IN (SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_TASK_COMMENT WHERE TASK_ID IN(SELECT ID FROM TEMP_CLEANUP);
	DELETE FROM HT_TASK WHERE ID IN(SELECT ID FROM TEMP_CLEANUP);
	COMMIT;
	PRINT ' End deleting task instance data with instance ids ';
END
GO

BEGIN
  PRINT (' Starting cleanTaskInstance procedure ');
  EXEC cleanTaskInstance;
  PRINT (' Ending cleanTaskInstance procedure ');
END
GO

DROP TABLE TEMP_CLEANUP;
GO