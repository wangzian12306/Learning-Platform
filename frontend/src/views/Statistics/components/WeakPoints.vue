<template>
  <el-card shadow="always">
    <template #header>
      <span>⚠️ 薄弱知识点</span>
    </template>
    <el-table :data="tableData" style="width: 100%" :height="280">
      <el-table-column prop="name" label="知识点" />
      <el-table-column prop="module" label="模块" width="80" />
      <el-table-column prop="masteryLevel" label="掌握程度" width="100">
        <template #default="{ row }">
          <el-tag :type="getMasteryTagType(row.masteryLevel)" size="small">
            {{ row.masteryLevel }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="correctRate" label="正确率" width="80">
        <template #default="{ row }">
          {{ row.correctRate }}%
        </template>
      </el-table-column>
      <el-table-column label="建议" width="100">
        <template #default="{ row }">
          <span v-if="row.correctRate < 50" style="color: #F56C6C">建议复习</span>
          <span v-else style="color: #E6A23C">继续练习</span>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup>
const props = defineProps({
  data: {
    type: Array,
    default: () => []
  }
})

const mockData = [
  { name: '二叉树遍历', module: '树', masteryLevel: '未掌握', correctRate: 40 },
  { name: '快速排序', module: '排序', masteryLevel: '基本掌握', correctRate: 65 },
  { name: '图的遍历', module: '图', masteryLevel: '未掌握', correctRate: 50 },
  { name: '红黑树', module: '树', masteryLevel: '未掌握', correctRate: 35 },
  { name: 'KMP 算法', module: '线性表', masteryLevel: '基本掌握', correctRate: 60 }
]

const tableData = props.data.length > 0 ? props.data : mockData

const getMasteryTagType = (level) => {
  const map = {
    '未掌握': 'danger',
    '基本掌握': 'warning',
    '掌握': 'success'
  }
  return map[level] || 'info'
}
</script>

<style scoped>
</style>