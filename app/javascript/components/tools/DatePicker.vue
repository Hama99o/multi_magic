<template>
  <v-dialog v-model="dialog" width="auto">
    <template #activator="{ props, isActive }">
      <slot :props="props" name="activator" :isActive="isActive">
        <v-btn text="Activate" />
      </slot>
    </template>
    <template #default>
      <v-date-picker
        v-model="date"
        @update:model-value="save"
        :rounded="true"
        color="purple"
      />
    </template>
  </v-dialog>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

const emit = defineEmits(['save'])

const props = defineProps({
  dateValue: { type: String, default: undefined },
})

onMounted(() => {
  date.value = props.dateValue ? new Date(props.dateValue) : new Date()
})

const date = ref(new Date());
const dialog = ref(false);

const closeDialog = () => {
  dialog.value = false;
};

const save = () => {
  emit('save', date.value)
  dialog.value = false
}

watch(props, (newValue, oldValue) => {
  if (newValue.dateValue) {
    date.value = newValue.dateValue ? new Date(newValue.dateValue) : new Date()
  }
})

defineExpose({
  dialog,
})
</script>
