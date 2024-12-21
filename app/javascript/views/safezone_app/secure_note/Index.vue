<template>
  <!-- Secure Notes Section -->
  <v-row>
    <v-col v-for="note in secureNotes" :key="note.id" cols="12" sm="6" md="4" lg="3">
      <v-card
        variant="outlined"
        class="cursor-pointer hover:border-primary"
        @click="selectNote(note)"
      >
        <v-card-item>
          <div class="d-flex align-center">
            <v-avatar size="40" rounded="lg" color="primary" class="mr-4">
              <v-icon icon="mdi-note-text" color="white"></v-icon>
            </v-avatar>
            <div class="flex-grow-1">
              <v-card-title class="pa-0 text-body-1 font-medium">
                {{ note.title }}
              </v-card-title>
              <v-card-subtitle class="pa-0 text-gray-500">
                {{ note.content.substring(0, 30) }}...
              </v-card-subtitle>
            </div>
          </div>
          <div class="mt-2 text-sm text-gray-400">Last edited {{ note.lastEdited }}</div>
        </v-card-item>
      </v-card>
    </v-col>
  </v-row>
</template>

<script setup>
import { ref } from 'vue';

const secureNotes = ref([
  {
    id: 1,
    title: 'Work Project Ideas',
    content: 'Brainstorming ideas for the new marketing campaign...',
    lastEdited: '1 day ago',
  },
  {
    id: 2,
    title: 'Personal Goals',
    content: '1. Learn a new language\n2. Run a marathon\n3. Start a side business',
    lastEdited: '1 week ago',
  },
  {
    id: 3,
    title: 'Gift Ideas',
    content: 'Mom: Cookbook\nDad: Golf clubs\nSister: Spa day',
    lastEdited: '2 weeks ago',
  },
]);

const selectNote = (note) => {
  // Implement note selection functionality
  console.log('Selected note:', note);
};
</script>

<style>
.v-list-item--active {
  background-color: rgb(var(--v-theme-primary));
  color: white;
}

.v-list-item--active .v-list-item__prepend {
  color: white;
}
</style>
