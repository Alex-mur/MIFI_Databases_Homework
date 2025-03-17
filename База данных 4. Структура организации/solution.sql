-- Задача 1
-- 
-- Условие
-- 
-- Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1), включая их подчиненных и подчиненных подчиненных. Для каждого сотрудника вывести следующую информацию:
-- 
--     EmployeeID: идентификатор сотрудника.
--     Имя сотрудника.
--     ManagerID: Идентификатор менеджера.
--     Название отдела, к которому он принадлежит.
--     Название роли, которую он занимает.
--     Название проектов, к которым он относится (если есть, конкатенированные в одном столбце через запятую).
--     Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце через запятую).
--     Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
-- 
-- Требования:
-- 
--     Рекурсивно извлечь всех подчиненных сотрудников Ивана Иванова и их подчиненных.
--     Для каждого сотрудника отобразить информацию из всех таблиц.
--     Результаты должны быть отсортированы по имени сотрудника.
--     Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово RECURSIVE.

WITH RECURSIVE Subordinates AS (
    -- Базовый случай: начинаем с 1
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1

    UNION ALL

    -- Рекурсивный случай: находим всех подчиненных
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN Subordinates s ON e.ManagerID = s.EmployeeID
)

SELECT 
    s.EmployeeID,
    s.Name AS EmployeeName,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS Projects,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS Tasks
FROM Subordinates s
LEFT JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON s.RoleID = r.RoleID
LEFT JOIN Projects p ON s.DepartmentID = p.DepartmentID
LEFT JOIN Tasks t ON s.EmployeeID = t.AssignedTo
GROUP BY 
    s.EmployeeID, 
    s.Name, 
    s.ManagerID, 
    d.DepartmentName, 
    r.RoleName
ORDER BY s.Name;



-- Задача 2
-- 
-- Условие
-- 
-- Найти всех сотрудников, подчиняющихся Ивану Иванову с EmployeeID = 1, включая их подчиненных и подчиненных подчиненных. Для каждого сотрудника вывести следующую информацию:
-- 
--     EmployeeID: идентификатор сотрудника.
--     Имя сотрудника.
--     Идентификатор менеджера.
--     Название отдела, к которому он принадлежит.
--     Название роли, которую он занимает.
--     Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
--     Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
--     Общее количество задач, назначенных этому сотруднику.
--     Общее количество подчиненных у каждого сотрудника (не включая подчиненных их подчиненных).
--     Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
-- 
-- Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово RECURSIVE.


WITH RECURSIVE Subordinates AS (
    -- Базовый случай: начинаем с Ивана Иванова
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1

    UNION ALL

    -- Рекурсивный случай: находим всех подчиненных
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN Subordinates s ON e.ManagerID = s.EmployeeID
),
EmployeeData AS (
    SELECT 
        s.EmployeeID,
        s.Name AS EmployeeName,
        s.ManagerID,
        d.DepartmentName,
        r.RoleName,
        GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS Projects,
        GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS Tasks,
        COUNT(DISTINCT t.TaskID) AS TotalTasks,
        (SELECT COUNT(*) FROM Employees e2 WHERE e2.ManagerID = s.EmployeeID) AS TotalSubordinates
    FROM Subordinates s
    LEFT JOIN Departments d ON s.DepartmentID = d.DepartmentID
    LEFT JOIN Roles r ON s.RoleID = r.RoleID
    LEFT JOIN Projects p ON s.DepartmentID = p.DepartmentID
    LEFT JOIN Tasks t ON s.EmployeeID = t.AssignedTo
    GROUP BY 
        s.EmployeeID, 
        s.Name, 
        s.ManagerID, 
        d.DepartmentName, 
        r.RoleName
)

SELECT 
    EmployeeID,
    EmployeeName,
    ManagerID,
    DepartmentName,
    RoleName,
    Projects,
    Tasks,
    TotalTasks,
    TotalSubordinates
FROM EmployeeData
ORDER BY EmployeeName;


-- Задача 3
-- Условие
-- 
-- Найти всех сотрудников, которые занимают роль менеджера и имеют подчиненных (то есть число подчиненных больше 0). Для каждого такого сотрудника вывести следующую информацию:
-- 
--     EmployeeID: идентификатор сотрудника.
--     Имя сотрудника.
--     Идентификатор менеджера.
--     Название отдела, к которому он принадлежит.
--     Название роли, которую он занимает.
--     Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
--     Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
--     Общее количество подчиненных у каждого сотрудника (включая их подчиненных).
--     Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
-- 
-- Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово RECURSIVE.


WITH RECURSIVE ManagerHierarchy AS (
    -- Базовый случай: находим всех сотрудников, у которых есть подчиненные
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        0 AS Level
    FROM Employees e
    WHERE EXISTS (
        SELECT 1
        FROM Employees e2
        WHERE e2.ManagerID = e.EmployeeID
    )

    UNION ALL

    -- Рекурсивный случай: находим всех подчиненных текущих менеджеров
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        mh.Level + 1
    FROM Employees e
    INNER JOIN ManagerHierarchy mh ON e.ManagerID = mh.EmployeeID
),
ManagerData AS (
    SELECT 
        mh.EmployeeID,
        mh.Name AS EmployeeName,
        mh.ManagerID,
        d.DepartmentName,
        r.RoleName,
        GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS Projects,
        GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS Tasks,
        COUNT(DISTINCT mh2.EmployeeID) AS TotalSubordinates
    FROM ManagerHierarchy mh
    LEFT JOIN Departments d ON mh.DepartmentID = d.DepartmentID
    LEFT JOIN Roles r ON mh.RoleID = r.RoleID
    LEFT JOIN Projects p ON mh.DepartmentID = p.DepartmentID
    LEFT JOIN Tasks t ON mh.EmployeeID = t.AssignedTo
    LEFT JOIN ManagerHierarchy mh2 ON mh.EmployeeID = mh2.ManagerID
    WHERE mh.Level = 0 -- Учитываем только менеджеров (уровень 0)
    GROUP BY 
        mh.EmployeeID, 
        mh.Name, 
        mh.ManagerID, 
        d.DepartmentName, 
        r.RoleName
)

SELECT 
    EmployeeID,
    EmployeeName,
    ManagerID,
    DepartmentName,
    RoleName,
    Projects,
    Tasks,
    TotalSubordinates
FROM ManagerData
WHERE RoleName = 'Менеджер'
ORDER BY EmployeeName;