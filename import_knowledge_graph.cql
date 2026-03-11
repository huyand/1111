// ============================================
// Neo4j 知识图谱导入脚本
// ============================================
// 使用方法：
// 1. 将 CSV 文件放入 Neo4j import 目录
// 2. 确保 Neo4j 已安装 APOC 插件
// 3. 依次执行以下各部分的语句

// ============================================
// 第一部分：创建索引（推荐先执行）
// ============================================
CREATE INDEX IF NOT EXISTS FOR (n:节点) ON (n.节点ID);
CREATE INDEX IF NOT EXISTS FOR (n:节点) ON (n.节点类型);
CREATE INDEX IF NOT EXISTS FOR (n:节点) ON (n.节点名称);

// ============================================
// 第二部分：导入节点
// ============================================
LOAD CSV WITH HEADERS FROM 'file:///import_nodes.csv' AS row
MERGE (n:节点 {节点ID: row.节点ID})
SET n.节点名称 = row.节点名称,
    n.节点类型 = row.节点类型,
    n.通用属性1 = row.通用属性1,
    n.通用属性2 = row.通用属性2,
    n.通用属性3 = row.通用属性3,
    n.扩展字段1 = row.扩展字段1,
    n.扩展字段2 = row.扩展字段2,
    n.备注 = row.备注
RETURN count(*);

// ============================================
// 第三部分：导入通用关系
// ============================================
LOAD CSV WITH HEADERS FROM 'file:///import_relationships.csv' AS row
MATCH (start:节点 {节点ID: row.`:START_ID`})
MATCH (end:节点 {节点ID: row.`:END_ID`})
CALL apoc.create.relationship(start, row.关系类型, {
    通用关系说明: row.通用关系说明,
    个性化扩展说明: row.个性化扩展说明,
    是否个性化: row.是否个性化,
    备注: row.备注
}, end) YIELD rel
RETURN count(rel);

// ============================================
// 第四部分：导入知识点掌握要求关系
// ============================================
LOAD CSV WITH HEADERS FROM 'file:///import_knowledge_level.csv' AS row
MATCH (knowledge:节点 {节点ID: row.`:START_ID`})
MATCH (level:节点 {节点ID: row.`:END_ID`})
CALL apoc.create.relationship(knowledge, '知识点-掌握要求', {
    要求ID: row.要求ID,
    掌握级别: row.掌握级别,
    通用核心要求: row.通用核心要求,
    个性化掌握要求: row.个性化掌握要求,
    备注: row.备注
}, level) YIELD rel
RETURN count(rel);

// ============================================
// 验证导入结果
// ============================================
MATCH (n:节点) RETURN n.节点类型, count(n) AS 数量;
MATCH (n:节点)-[r]->() RETURN type(r), count(r) AS 数量;
