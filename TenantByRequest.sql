-- =============================================
-- Author:		Upendra Dahal
-- Create date: 05/06/2018
-- q. Tenant by request with search, sort and pagination.
-- =============================================
Create PROCEDURE [dbo].[SP_SearchSortPagingTenantByRequestInfo]
@Start     INT=0, 
@PageLimit INT=10,
@Tenantid NVARCHAR(20),
@propertyname NVARCHAR(100),
@budget MONEY,
@SortColumn NVARCHAR(100) = 'Property'
AS
BEGIN
		SELECT OP.OwnerId,P.[Name] PropertyName,ISNULL(PE.FirstName,'')+' '+ISNULL(PE.MiddleName,'')+' '+ISNULL(PE.LastName,'') TenantName 
		,A.Number+' '+A.Street+' '+A.City+' '+A.Suburb+' '+A.Region+' '+A.PostCode PropertyAddress,TP.TenantId,TJS.[Name] JobStatus,TJR.JobDescription,TJR.MaxBudget,TJR.Title,TM.NewFileName		
		,* FROM TenantJobRequest TJR 
		INNER JOIN TenantJobStatus TJS ON TJS.Id=TJR.JobStatusId
		INNER JOIN OwnerProperty OP
		ON OP.PropertyId=TJR.PropertyId
		INNER JOIN Property P
		ON p.Id=op.PropertyId
		INNER JOIN [Address] A
		ON A.AddressId=p.AddressId
		LEFT JOIN TenantJobRequestMedia TM 
		ON TM.TenantJobRequestId=TJR.Id
		INNER JOIN TenantProperty TP 
		ON TP.PropertyId=P.Id
		INNER JOIN Person PE
		ON PE.Id=TP.TenantId
	    WHERE OP.OwnerId = @Tenantid
		AND P.[Name] like '%'+@propertyname+'%'
		AND TJR.MaxBudget >=@budget  
		ORDER  BY 
		CASE 
		WHEN @SortColumn LIKE '%Property%' THEN P.[Name]  
		WHEN @SortColumn LIKE '%JobDescription%' THEN TJR.JobDescription  
		WHEN @SortColumn LIKE '%Status%' THEN TJS.[Name] 
		END	ASC
OFFSET @Start ROW
FETCH NEXT @PageLimit ROWS ONLY
END

--EXEC SP_SearchSortPagingTenantByRequestInfo 1,5,'348','North Road',500,'Property'
