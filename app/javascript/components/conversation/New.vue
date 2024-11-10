<template>
  <v-dialog v-model="dialog" max-width="600px">
    <v-card class="elevation-3 rounded-lg">
      <!-- Dialog Header -->
      <v-card-title class="d-flex justify-space-between align-center py-3">
        <span class="text-h5 font-semibold">Start New Conversation</span>
        <v-btn icon @click="closeDialog">
          <v-icon class="text-primary">mdi-close</v-icon>
        </v-btn>
      </v-card-title>

      <!-- Dialog Body -->
      <v-card-text>
        <!-- Conversation Mode Toggle -->
        <v-row class="d-flex align-center justify-center mb-4">
          <v-chip-group v-model="isGroupChat" row class="bg-grey-lighten-4 rounded-md">
            <v-chip :value="false" class="mr-2 text-body-1 font-semibold">Single User</v-chip>
            <v-chip :value="true" class="text-body-1 font-semibold">Group Chat</v-chip>
          </v-chip-group>
        </v-row>

        <!-- Group Name Input for Group Chat Mode -->
        <v-row v-if="isGroupChat" class="mb-4">
          <v-col>
            <v-text-field
              v-model="groupName"
              label="Group Name"
              placeholder="Enter a group name..."
              dense
              outlined
              required
              hide-details
            ></v-text-field>
          </v-col>
        </v-row>

        <!-- Search Input / Multi-User Select for Group Chat -->
        <v-row>
          <v-col v-if="isGroupChat">
            <v-autocomplete
              :key="generator"
              ref="parentTagAutocomplete"
              v-model="selectedUsers"
              :items="searchResults"
              item-title="fullname"
              item-value="id"
              placeholder="Select a Category"
              clearable
              required
              variant="solo-filled"
              multiple
              hide-details
              :disabled="article?.tags?.length >= 3"
              :max="4"
              clear-icon="mdi-close"
              @update:model-value="updateTags"
              @update:search="searchTags"
            >
              <template #append-item>
                <div v-intersect="onIntersect" />
              </template>
            </v-autocomplete>
          </v-col>
          <v-col v-else>
            <v-text-field
              v-model="searchQuery"
              placeholder="Search for users..."
              prepend-inner-icon="mdi-magnify"
              @input="searchUsers"
              dense
              outlined
              class="mb-4"
              hide-details
            ></v-text-field>
          </v-col>
        </v-row>

        <!-- Single-User List for Direct Messages -->
        <v-list dense v-if="!isGroupChat">
          <v-list-item
            v-for="user in searchResults"
            :key="user.id"
            @click="$emit('createNewConversation', user)"
            class="flex cursor-pointer hover:bg-primary-lighten-5 rounded-lg py-2 px-3"
          >
            <!-- User Info Section -->
            <div class="flex">
              <!-- Avatar Section -->
              <user-avatar
                :isOnline="user?.is_online"
                class="cursor-pointer mr-5"
                size="lg"
                :avatar="user?.avatar"
                :firstname="user?.firstname"
                :lastname="user?.lastname"
              />
              <span>
                <v-list-item-title>{{ user.fullname }}</v-list-item-title>
                <v-list-item-subtitle>{{ user.email }}</v-list-item-subtitle>
              </span>
            </div>
          </v-list-item>
        </v-list>

        <!-- Confirmation Button -->
        <v-row v-if="isGroupChat" class="d-flex justify-end mt-4">
          <v-btn
            :disabled="isGroupChat ? selectedUsers.length === 0 : !selectedUser"
            color="primary"
            @click="confirmSelection"
          >
            <v-icon left>mdi-send</v-icon>
            Start Group Chat
          </v-btn>
        </v-row>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import UserAvatar from '@/components/tools/Avatar.vue';
import { ref, watch } from 'vue';

const props = defineProps({
  searchResults: { type: Array, default: () => [] }
});

const dialog = ref(false);
const groupName = ref('Group Conversation')
const isGroupChat = ref(false);          // Toggle for group chat mode
const searchQuery = ref('');              // For single-user search input
const selectedUsers = ref([]);            // For selected users in group chat mode
const selectedUser = ref(null);           // For selected single user in direct chat

// Emit events to parent component
const emit = defineEmits(['searchUsers', 'createNewConversation', 'createNewGroupConversation']);

const searchUsers = () => {
  emit('searchUsers', searchQuery.value);
};

// Close the dialog
const closeDialog = () => {
  dialog.value = false;
};

// Confirm selection and start conversation
const confirmSelection = () => {
  // Emit event for group chat with multiple users
  emit('createNewGroupConversation', selectedUsers.value, groupName.value);
  closeDialog();
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog
});
</script>

<style scoped>
.dialog {
  background-color: var(--v-surface);
}
.hover\:bg-primary-lighten-5:hover {
  background-color: rgba(0, 0, 255, 0.05); /* Lightened primary color */
}
</style>
