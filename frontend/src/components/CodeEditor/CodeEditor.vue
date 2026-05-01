<template>
  <MonacoEditor
    :language="language"
    :value="modelValue"
    :options="editorOptions"
    style="height: 100%; min-height: 300px;"
    @update:value="$emit('update:modelValue', $event)"
  />
</template>

<script setup>
import MonacoEditor from 'monaco-editor-vue3'

defineProps({
  modelValue: { type: String, default: '' },
  language: { type: String, default: 'cpp' }
})

defineEmits(['update:modelValue'])

const editorOptions = {
  theme: 'vs',
  fontSize: 14,
  minimap: { enabled: false },
  scrollBeyondLastLine: false,
  automaticLayout: true,
  tabSize: 4
}
</script>
