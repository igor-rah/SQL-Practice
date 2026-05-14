CREATE TABLE #T (b int, e int, w int)

INSERT #T
VALUES (1, 2, 1), (1, 3, 5), (2, 3, 16), (2, 6, 1), (3, 4, 1), (3, 5, 1);

CREATE TABLE #FT (b int, e int, w int, path varchar(100))

INSERT #FT
SELECT b, e, w, CAST(CONCAT(b, '-', e) AS varchar(100))
FROM (VALUES(1, 2, 1), (1, 3, 5), (2, 3, 16), (2, 6, 1), (3, 4, 1), (3, 5, 1)) AS V(b, e, w)

DECLARE @count_ AS INT = 1

WHILE @count_ > 0
BEGIN 
	SET @count_ = 
	(
		SELECT COUNT(*)
		FROM 
		(
			SELECT T1.b, T2.e, T1.w * T2.w AS w,
				CAST(CONCAT(T1.path, '-', T2.e) AS varchar(100)) AS path
			FROM #FT AS T1 INNER JOIN #T AS T2 ON
				T1.e = T2.b
		) AS NEW LEFT JOIN #FT ON
			#FT.path = NEW.path
		WHERE #FT.b IS NULL
	)

	INSERT #FT
	SELECT NEW.b, NEW.e, NEW.w, NEW.path
	FROM 
	(
		SELECT T1.b, T2.e, T1.w * T2.w AS w,
			CAST(CONCAT(T1.path, '-', T2.e) AS varchar(100)) AS path
		FROM #FT AS T1 INNER JOIN #T AS T2 ON
			T1.e = T2.b
	) AS NEW LEFT JOIN #FT ON
		#FT.path = NEW.path
	WHERE #FT.b IS NULL
END;

-- Считаем состав
WITH Leaves AS
(
	SELECT DISTINCT e AS leaf
	FROM #T
	WHERE e NOT IN (SELECT DISTINCT b FROM #FT)
)
SELECT #FT.b AS Изделие,
	#FT.e AS Компонента,
	SUM(#FT.w) AS Колво
FROM #FT INNER JOIN Leaves ON
	#FT.e = Leaves.leaf
WHERE #FT.b IN (
	SELECT DISTINCT b
	FROM #T
	WHERE b NOT IN (SELECT DISTINCT e FROM #T)
)
GROUP BY #FT.b, #FT.e
ORDER BY SUM(#FT.w) desc

SELECT * 
FROM #FT

DROP TABLE #T
DROP TABLE #FT

/* КАК И ПОЧЕМУ АЛГОРИТМ РАБОТАЕТ И РАБОТАЕТ КОРРЕКТНО?
1) Создание таблицы Т - в ней лежат исходные вершины графа с весами
2) Создаём нужную нам таблицу полного графа с путями - каждой вершине будет соответствовать начальная вершина,
конечная вершина (она сама), произведение весов пути, по которой можно в неё попасть и сам путь
3) После создания полного графа посчитать состав легко при помоши группировки