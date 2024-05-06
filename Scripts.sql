-- 1. აპლიკანტების სახელიდან და გვარიდან ამოვარჩიოთ უნიკალური სახელები და გვარები ცალ-ცალკე. 2 Select (სახელებისათვის, გვარებისათვის)

SELECT DISTINCT SUBSTRING(EntrantName, 0, CHARINDEX(' ', EntrantName)) AS FirstName FROM uni.Entrants
ORDER BY FirstName

SELECT DISTINCT SUBSTRING(EntrantName, CHARINDEX(' ', EntrantName) + 1, LEN(EntrantName)) AS LastName FROM uni.Entrants
ORDER BY LastName

-- 2. დავადგინოთ რომელიმე აპლიკანტი ხომ არ ცხოვრობს ისეთ ქუჩაზე რომელშიც ქვემიმდევრობად 
-- შეგვიძლია აღმოვაჩინოთ მისი სახელი. (მაგ: სახელი ანი, ქუჩა გიორგობიანის ქ# 45)

SELECT * FROM uni.Entrants
WHERE EntrantAddress LIKE '%' + SUBSTRING(EntrantName, 0, CHARINDEX(' ', EntrantName)) + '%'

-- ა) გავაკეთოთ რეპორტი რომელიც გვაჩვენებს თითეულ ფაკულტეტზე როგორია კონკურსი. - 15 ქულა
-- გავაკეთოთ კოეფიციენტი (მოთხოვნა/მიწოდებაზე(float)).(მაგ: არა მხოლოდ თსუ-ს იურიდიულზე არამედ ყველა უნის იურიდიულზე ერთად)

SELECT T1.FacultyID, CONVERT(FLOAT, T1.TotalQuotas) / CONVERT(FLOAT, COUNT(ApplicantID)) AS Coeficient FROM
(
	SELECT FacultyID, SUM(Quotas) AS TotalQuotas FROM uni.UniversityFaculties
	GROUP BY FacultyID
) AS T1
JOIN 
(
	SELECT ApplicantID, FacultyID FROM uni.ApplicatRegistrations AS a
	JOIN uni.UniversityFaculties AS u ON a.UniversityFacultyID = u.UniversityFacultyID
) AS T2 ON T1.FacultyID = T2.FacultyID
GROUP BY T1.FacultyID, T1.TotalQuotas
ORDER BY T1.FacultyID

-- ბ) გავაკეთოთ რეპორტი რომელიც გვაჩვენებს თითეულ უნივერსიტეტში როგორია კონკურსი, გავაკეთოთ კოეფიციენტი.

SELECT T1.UniversityID, CONVERT(FLOAT, T1.TotalQuotas) / CONVERT(FLOAT, T2.TotalApplicants) AS Coeficient FROM
(
	SELECT UniversityID, SUM(Quotas) AS TotalQuotas FROM uni.UniversityFaculties
	GROUP BY UniversityID
) AS T1
JOIN 
(
	SELECT UniversityID, COUNT(ApplicantID) AS TotalApplicants FROM uni.ApplicatRegistrations AS a
	JOIN uni.UniversityFaculties AS u ON a.UniversityFacultyID = u.UniversityFacultyID
	GROUP BY UniversityID
) AS T2 ON T1.UniversityID = T2.UniversityID
ORDER BY T1.UniversityID

-- გ) თითიეული უნივერსიტეტის თითეულ ფაკულტეტზე როგორია კონკურსი.გავაკეთოთ კოეფიციენტი.

SELECT T2.UniversityID, T2.UniversityFacultyID, CONVERT(FLOAT, T2.Quotas) / CONVERT(FLOAT, T1.TotalApplicants) AS Coeficient FROM
(
	SELECT UniversityFacultyID, COUNT(*) AS TotalApplicants FROM uni.ApplicatRegistrations
	GROUP BY UniversityFacultyID
) AS T1
JOIN 
(
	SELECT * FROM uni.UniversityFaculties
) AS T2 ON T1.UniversityFacultyID = T2.UniversityFacultyID

-- დავადგინოთ რომელი სტუდენტები არ გამოცხადნენ გამოცდაზე მათი ქულა რეპორტში ვაჩვენოთ როგორც ნული. 
-- ვინც არ გამოცხადდა იმის ქულა არის NULL (არ არის Update) - 5 ქულა

SELECT  
	[ApplicantID],
	[UniversityFacultyID],
	[RegistrationDate],
	CASE WHEN [Score] IS NULL THEN 0
	ELSE [Score]
	END AS [Score]
FROM uni.ApplicatRegistrations
WHERE Score IS NULL

-- შემოვიტანოთ სტატუსი ქულების მიხედვით, 0-40 ამდე აპლიკანტებს მივაწეროთ დაბალი, 40-80-ამდე საშუალო, 
-- 80-100 ამდე მაღალი და დავთვალოთ რამდენი აპლიანტი მოხვდა ამ სამ სტატუსში. - 10 ქულა
-- მაღალი  | 1000
-- საშუალო | 7000
-- დაბალი   | 2000

SELECT  
	[ApplicantID],
	[UniversityFacultyID],
	[RegistrationDate],
	[Score],
	CASE WHEN [Score] BETWEEN 0 AND 40 THEN 'Low'
	WHEN [Score] BETWEEN 40 AND 80 THEN 'Middle'
	ELSE 'High'
	END AS [Status]
FROM uni.ApplicatRegistrations
WHERE Score IS NOT NULL
ORDER BY [Score]

-- დაწერეთ ისეთი Query- რომელიც რეპორტის სახით ამოიღებს ისეთ აბიტურიენტებს ვისი სახელი და გვარებიც ერთნაირია უბრალოდ რეგისტრაციისას მიუთითეს პირიქით,
-- (მაგ: David James, James David, გვაინტერესებს ეგეთი ადამიანები თუ იძებნება). - 15 ქულა

SELECT * FROM uni.Entrants
WHERE ApplicantID IN
(
	SELECT T1.ApplicantID FROM
	(
		SELECT * FROM
		(
			SELECT
				SUBSTRING(EntrantName, CHARINDEX(' ', EntrantName) + 1, LEN(EntrantName))
				+ ' ' +
				SUBSTRING(EntrantNAme, 0, CHARINDEX(' ', EntrantName)) AS FullName
			FROM uni.Entrants
		) AS T2
		JOIN uni.Entrants AS e ON e.EntrantName = T2.FullName
	) AS T1
)
AND SUBSTRING(EntrantName, 0, CHARINDEX(' ', EntrantName)) != SUBSTRING(EntrantName, CHARINDEX(' ', EntrantName) + 1, LEN(EntrantName))

-- 7. დავადგინოთ მეილის დომეინის ჭრილში ვინ დარეგისტრიტრა პირველი. (აბიტურიენტის მონაცემები) გავაკეთოთ ID-ით და არა თარიღით. - 10 ქულა

SELECT MIN(ApplicantID) AS ApplicantID, SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email)) AS Domain FROM uni.Entrants
GROUP BY SUBSTRING(Email, CHARINDEX('@', Email), LEN(Email))
ORDER BY ApplicantID

-- 8. თითეულ უნივერსიტეტის ფაკულტეტზე ვაჩვენოთ ვინ აიღო შესაბამის ადგილზე საშუალო ქულაზე მაღალი ქულა. იმავე უნის ფაკულტეტის საშუალოზე მაღალი. - 10 ქულა

SELECT * FROM
(
	SELECT UniversityFacultyID, AVG(Score) AS AverageScore FROM uni.ApplicatRegistrations
	GROUP BY UniversityFacultyID
) AS T1
JOIN
(
	SELECT * FROM uni.ApplicatRegistrations
) AS T2 ON T1.UniversityFacultyID = T2.UniversityFacultyID
WHERE T2.Score > T1.AverageScore
ORDER BY T1.UniversityFacultyID

-- 9. ა)ვაჩვენოთ თითეულ უნივერსიტეტს რამდენი ფაკულტეტზე აქვს გამოცხადებული მიღება. - 10 ქულა

SELECT UniversityID, COUNT(FacultyID) AS FacultyCount FROM uni.UniversityFaculties
GROUP BY UniversityID
ORDER BY FacultyCount

--  ბ)ვაჩვენოთ რამდენ უნივერსიტეტს რამდენ ფაკულტეტზე აქვს მიღება.

SELECT FacultyCount, COUNT(UniversityID) AS UniversityCount FROM 
(
	SELECT UniversityID, COUNT(FacultyID) AS FacultyCount FROM uni.UniversityFaculties
	GROUP BY UniversityID
) AS T1
GROUP BY T1.FacultyCount

-- 10. ცხრილების წყვილებს დავაწეროთ რა კავშირებია მათ შორის.  - 10 ქულა
-- PK-FK - ერთი - ერთთან და ა.შ 10 კავშირი.

-- ApplicantRegistrations - Entrants ერთი ერთთან კავშირი
-- ApplicantRegistrations - UniversityFaculties ერთი მრავალთან კავშირი
-- ApplicantRegistrations - Universities ერთი მრავალთან
-- ApplicantRegistrations - Faculties ერთი მრავალთან

-- Entrants - UniversityFaculties ერთი მრავალთან კავშირი
-- Entrants - Universities ერთი მრავალთან
-- Entrants - Faculties - ერთი მრავალთან

-- UniversityFaculties - Universities ერთი მრავალთან კავშირი
-- UniversityFaculties - Faculties ერთი მრავალთან კავშირი

-- Universities - Faculties მრავალი მრავალთან