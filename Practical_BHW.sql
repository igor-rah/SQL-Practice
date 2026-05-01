--Задание 2
DECLARE @id as int
SET @id = 2

SELECT *
FROM Polinomes
WHERE P_ID = @id

--Задание 3
SELECT P_ID
FROM Polinomes
GROUP BY P_ID
HAVING COUNT(Pow) = SUM(CASE WHEN Coef != 0 THEN 1 ELSE 0 END)

--Задание 4
DECLARE @m_id as int, @m_coef as float
SET @m_id = 3
SET @m_coef = 4.5

SELECT P_ID, Pow, Coef * @m_coef as New_coef
FROM Polinomes
WHERE P_ID = @m_id

--Задание 5
DECLARE @check_id as int, @check_pow as float
SET @check_id = 3
SET @check_pow = 2

SELECT 
	P_ID,
	CASE WHEN MAX(CASE WHEN Coef != 0 THEN Pow END) = @check_pow THEN 'Да' ELSE 'Нет' END as Res
FROM Polinomes
WHERE P_ID = @check_id
GROUP BY P_ID

--Задание 6
DECLARE @s_id_1 as int, @s_id_2 as int
SET @s_id_1 = 1
SET @s_id_2 = 6

SELECT
	Pow,
	SUM(Coef) as Res_coef
FROM (
	SELECT P_ID, Pow, Coef
	FROM Polinomes
	WHERE P_ID = @s_id_1 

	UNION ALL

	SELECT P_ID, Pow, Coef 
	FROM Polinomes
	WHERE P_ID = @s_id_2 
) AS T
GROUP BY Pow
HAVING SUM(Coef) != 0

--Задание 7
DECLARE @m_id_1 as int, @m_id_2 as int
SET @m_id_1 = 5
SET @m_id_2 = 6

SELECT
	p1.Pow + p2.Pow as Res_pow,
	SUM(p1.Coef * p2.Coef) as Res_coef
FROM Polinomes as p1, Polinomes as p2
WHERE p1.P_ID = @m_id_1 AND p2.P_ID = @m_id_2
GROUP BY p1.Pow + p2.Pow
HAVING SUM(p1.Coef * p2.Coef) != 0

--Задание 8
DECLARE @r_id as int, @x as int
SET @r_id = 3
SET @x = 6

SELECT SUM(Coef * POWER(@x, Pow)) as Res
FROM Polinomes
WHERE P_ID = @r_id

--Задание 9
DECLARE @check_id_9 AS INT
SET @check_id_9 = 5

DECLARE @a FLOAT, @b FLOAT, @c FLOAT, @mp INT

SELECT @a = Coef FROM Polinomes WHERE P_ID = @check_id_9 AND Pow = 2
SELECT @b = Coef FROM Polinomes WHERE P_ID = @check_id_9 AND Pow = 1
SELECT @c = Coef FROM Polinomes WHERE P_ID = @check_id_9 AND Pow = 0
SELECT @mp = MAX(Pow) FROM Polinomes WHERE P_ID = @check_id_9 AND Coef != 0

SELECT
    CASE WHEN @mp = 2 AND POWER(@b, 2) = 4 * @a * @c THEN 'Да' ELSE 'Нет' END AS Result

--Задание 10
DECLARE @check_id_10 AS INT, @mp_1 as int
SET @check_id_10 = 5

SELECT @mp_1 = MAX(Pow) FROM Polinomes WHERE P_ID = @check_id_10 and Coef != 0

SELECT COALESCE(SUM(CASE WHEN Coef = 0 THEN 1 END), 0) as Zeros, COALESCE(SUM(CASE WHEN Coef > 0 THEN 1 END), 0) as Pos, COALESCE(SUM(CASE WHEN Coef < 0 THEN 1 END), 0) as Neg
FROM Polinomes
WHERE P_ID = @check_id_10 and Pow <= @mp_1
GROUP BY P_ID 

--Задание 11
DECLARE @check_id_11 AS INT
SET @check_id_11 = 5

SELECT CASE WHEN SUM(CASE WHEN CAST(Coef as INT) = Coef OR Coef = 0 THEN 1 END) = COUNT(*) THEN 'Да' ELSE 'Нет' END AS Result
FROM Polinomes
WHERE P_ID = @check_id_11 

--Задание 12
DECLARE @check_id_12 AS INT
SET @check_id_12 = 5

SELECT CASE WHEN MAX(CASE WHEN Coef != 0 THEN Pow END) = 1 AND MAX(CASE WHEN Pow = 1 THEN Coef END) != 0 
			THEN CAST(ROUND(-1.0 * MAX(CASE WHEN Pow = 0 THEN Coef END) / MAX(CASE WHEN Pow = 1 THEN Coef END),2) AS VARCHAR(50)) ELSE 'Нет' END AS Res
FROM Polinomes
WHERE P_ID = @check_id_12
GROUP BY P_ID

--Задание 13
DECLARE @check_id_13 AS INT
SET @check_id_13 = 1

SELECT 
    CASE WHEN MAX(CASE WHEN Coef != 0 THEN Pow END) = 2 AND MAX(CASE WHEN Pow = 2 THEN Coef END) != 0 
         THEN CASE WHEN POWER(MAX(CASE WHEN Pow = 1 THEN Coef END), 2) - 4 * MAX(CASE WHEN Pow = 2 THEN Coef END) * MAX(CASE WHEN Pow = 0 THEN Coef END) > 0 
                   THEN 
                    'Два корня: ' + CAST(ROUND((-MAX(CASE WHEN Pow = 1 THEN Coef END) + SQRT(POWER(MAX(CASE WHEN Pow = 1 THEN Coef END), 2) - 4 * MAX(CASE WHEN Pow = 2 THEN Coef END) * 
                                    MAX(CASE WHEN Pow = 0 THEN Coef END))) / (2 * MAX(CASE WHEN Pow = 2 THEN Coef END)), 2) AS VARCHAR(50)) +
                            '  и '+ CAST(ROUND((-MAX(CASE WHEN Pow = 1 THEN Coef END) - SQRT(POWER(MAX(CASE WHEN Pow = 1 THEN Coef END), 2) - 4 * MAX(CASE WHEN Pow = 2 THEN Coef END) * 
                                    MAX(CASE WHEN Pow = 0 THEN Coef END))) / (2 * MAX(CASE WHEN Pow = 2 THEN Coef END)), 2) AS VARCHAR(50))
                
                    WHEN POWER(MAX(CASE WHEN Pow = 1 THEN Coef END), 2) - 4 * MAX(CASE WHEN Pow = 2 THEN Coef END) * MAX(CASE WHEN Pow = 0 THEN Coef END) = 0 
                    THEN 'Один корень: x = ' + CAST(ROUND(-MAX(CASE WHEN Pow = 1 THEN Coef END) / (2 * MAX(CASE WHEN Pow = 2 THEN Coef END)), 2) AS VARCHAR(50))
                
                    ELSE 'Нет корней'
                    END
        ELSE 'Не 2я степень'
    END AS Res
FROM Polinomes
WHERE P_ID = @check_id_13
GROUP BY P_ID

--Задание 14
DECLARE @poly_id_1 AS INT, @poly_id_2 AS INT, @poly_id_3 AS INT
SET @poly_id_1 = 5
SET @poly_id_2 = 6  
SET @poly_id_3 = 7

SELECT 
    CASE WHEN mult_pol.mult_all = mult_pol.p3_total AND mult_pol.matched = mult_pol.p3_total THEN 'Да' ELSE 'Нет' END AS Res
FROM 
    (SELECT 
        (SELECT COUNT(*) FROM (SELECT p1.Pow + p2.Pow as Pow, SUM(p1.Coef * p2.Coef) as Coef
                              FROM Polinomes p1
                              INNER JOIN Polinomes p2 ON p1.P_ID = @poly_id_1 AND p2.P_ID = @poly_id_2
                              GROUP BY p1.Pow + p2.Pow
                              HAVING SUM(p1.Coef * p2.Coef) != 0) AS t1) AS mult_all, -- задание 7
        
        (SELECT COUNT(*) FROM Polinomes WHERE P_ID = @poly_id_3 AND Coef != 0) AS p3_total,
        
        (SELECT COUNT(*) 
         FROM (SELECT p1.Pow + p2.Pow as Pow, SUM(p1.Coef * p2.Coef) as Coef
               FROM Polinomes p1
               INNER JOIN Polinomes p2 ON p1.P_ID = @poly_id_1 AND p2.P_ID = @poly_id_2
               GROUP BY p1.Pow + p2.Pow
               HAVING SUM(p1.Coef * p2.Coef) != 0) AS mult
         INNER JOIN Polinomes p3 ON mult.Pow = p3.Pow AND mult.Coef = p3.Coef
         WHERE p3.P_ID = @poly_id_3) AS matched
    ) AS mult_pol

--Задание 15
DECLARE @poly_id_4 AS INT, @poly_id_5 AS INT, @poly_id_6 AS INT
SET @poly_id_4 = 3
SET @poly_id_5 = 4  
SET @poly_id_6 = 2

SELECT 
    CASE WHEN mult_pol.mult_all = mult_pol.p3_total AND mult_pol.matched = mult_pol.p3_total THEN 'Да' ELSE 'Нет' END AS Res
FROM 
    (SELECT 
        (SELECT COUNT(*) FROM (SELECT p2.Pow + p3.Pow as Pow, SUM(p2.Coef * p3.Coef) as Coef
                              FROM Polinomes p2
                              INNER JOIN Polinomes p3 ON p2.P_ID = @poly_id_5 AND p3.P_ID = @poly_id_6
                              GROUP BY p2.Pow + p3.Pow
                              HAVING SUM(p2.Coef * p3.Coef) != 0) AS t1) AS mult_all, 
        
        (SELECT COUNT(*) FROM Polinomes WHERE P_ID = @poly_id_4 AND Coef != 0) AS p3_total, 
        
        (SELECT COUNT(*) 
         FROM (SELECT p2.Pow + p3.Pow as Pow, SUM(p2.Coef * p3.Coef) as Coef
               FROM Polinomes p2
               INNER JOIN Polinomes p3 ON p2.P_ID = @poly_id_5 AND p3.P_ID = @poly_id_6
               GROUP BY p2.Pow + p3.Pow
               HAVING SUM(p2.Coef * p3.Coef) != 0) AS mult
         INNER JOIN Polinomes p1 ON mult.Pow = p1.Pow AND mult.Coef = p1.Coef
         WHERE p1.P_ID = @poly_id_4) AS matched 
    ) AS mult_pol