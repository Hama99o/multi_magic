<template>
  <div
    class="todo-item flex items-start gap-3 px-4 py-3 border-b transition-colors group"
    :class="{ 'opacity-60': todo.completed }"
  >
    <!-- Checkbox -->
    <v-checkbox
      :model-value="todo.completed"
      hide-details
      density="compact"
      class="mt-0.5 flex-shrink-0"
      @update:model-value="$emit('toggle')"
    ></v-checkbox>

    <!-- Main Content -->
    <div class="flex-1 min-w-0">
      <!-- Title -->
      <div v-if="isEditingTitle" class="flex items-center gap-2">
        <v-text-field
          v-model="editTitle"
          variant="outlined"
          density="compact"
          hide-details
          autofocus
          class="flex-1"
          @keyup.enter="saveTitle"
          @keyup.esc="cancelEdit"
          @blur="saveTitle"
        ></v-text-field>
      </div>
      <div
        v-else
        class="cursor-pointer font-medium text-sm leading-relaxed"
        :class="{ 'line-through opacity-50': todo.completed }"
        @click="startEditTitle"
      >
        {{ todo.title }}
      </div>

      <!-- Group Name (for search results) -->
      <div v-if="showGroup && groupName" class="mt-1">
        <v-chip size="x-small" variant="tonal">
          <v-icon start size="10">mdi-folder</v-icon>
          {{ groupName }}
        </v-chip>
      </div>

      <!-- Notes -->
      <div v-if="showNotesInput || todo.notes" class="mt-2">
        <v-textarea
          v-if="showNotesInput"
          v-model="editNotes"
          variant="outlined"
          density="compact"
          rows="2"
          hide-details
          placeholder="Add notes..."
          class="text-sm"
          @blur="saveNotes"
          @keyup.esc="showNotesInput = false"
        ></v-textarea>
        <p
          v-else-if="todo.notes"
          class="text-xs opacity-70 cursor-pointer transition-colors line-clamp-2"
          @click="startEditNotes"
        >
          <v-icon size="12" class="mr-1">mdi-note-text</v-icon>
          {{ todo.notes }}
        </p>
      </div>
    </div>

    <!-- Actions -->
    <div class="flex items-center gap-1">
      <v-btn
        v-if="!todo.notes && !showNotesInput"
        icon
        size="x-small"
        variant="text"
        class="!text-primary hover:bg-gray-800"
        @click="startEditNotes"
      >
        <v-icon size="16">mdi-note-plus-outline</v-icon>
        <v-tooltip activator="parent" location="top">Add notes</v-tooltip>
      </v-btn>
      <v-btn
        icon
        size="x-small"
        variant="text"
        class="!text-error hover:bg-gray-800"
        @click="$emit('delete')"
      >
        <v-icon size="16">mdi-delete-outline</v-icon>
        <v-tooltip activator="parent" location="top">Delete</v-tooltip>
      </v-btn>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  todo: {
    type: Object,
    required: true,
  },
  showGroup: {
    type: Boolean,
    default: false,
  },
  groupName: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['toggle', 'delete', 'update']);

const isEditingTitle = ref(false);
const editTitle = ref(props.todo.title);
const showNotesInput = ref(false);
const editNotes = ref(props.todo.notes || '');

watch(
  () => props.todo,
  (newTodo) => {
    editTitle.value = newTodo.title;
    editNotes.value = newTodo.notes || '';
  },
  { deep: true },
);

const startEditTitle = () => {
  editTitle.value = props.todo.title;
  isEditingTitle.value = true;
};

const saveTitle = () => {
  if (editTitle.value.trim() && editTitle.value !== props.todo.title) {
    emit('update', { title: editTitle.value.trim() });
  }
  isEditingTitle.value = false;
};

const cancelEdit = () => {
  editTitle.value = props.todo.title;
  isEditingTitle.value = false;
};

const startEditNotes = () => {
  editNotes.value = props.todo.notes || '';
  showNotesInput.value = true;
};

const saveNotes = () => {
  if (editNotes.value !== props.todo.notes) {
    emit('update', { notes: editNotes.value });
  }
  showNotesInput.value = false;
};
</script>

<style scoped>
.todo-item:last-child {
  border-bottom: none;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
