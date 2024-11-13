<template>
  <v-dialog v-model="dialog" max-width="700px">
    <v-card>
      <!-- Header with title and close button -->
      <v-toolbar color="primary" dark flat class="rounded-t-lg">
        <v-toolbar-title class="text-h6 font-bold">Manage Participants</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon @click="closeDialog">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-toolbar>

      <!-- Main Content -->
      <v-card-text class="py-4">
        <!-- Participant List -->
        <v-list dense>
          <v-list-item-group>
            <v-list-item
              v-for="participant in participants"
              :key="participant.user.id"
              class="flex items-center justify-between px-4 py-2 hover:bg-sky-700 rounded-lg"
            >
              <!-- User Info Section -->
              <div class="flex items-center justify-between">
                <AvatarWithUserInfo
                  class="cursor-pointer mr-1"
                  size="md"
                  :user="participant?.user"
                  withFullname
                  @update-user="participant.user.is_following = $event"
                >
                  <template #fullname>
                    <div>
                      <v-list-item-title class="font-medium">
                        {{ participant.user.fullname }}
                        <span v-if="participant.is_admin" class="text-xs font-semibold ml-2">(Admin)</span>
                      </v-list-item-title>
                      <v-list-item-subtitle class="text-gray-500">{{ participant.user.email }}</v-list-item-subtitle>
                    </div>
                  </template>
                </AvatarWithUserInfo>

                <!-- Remove Button for Group Admins -->
                <v-btn
                  v-if="canDeleteParticipants"
                  icon
                  color="red"
                  @click="removeParticipant(participant.user.id)"
                >
                  <v-icon>mdi-delete</v-icon>
                </v-btn>
              </div>

            </v-list-item>
          </v-list-item-group>
        </v-list>

        <!-- Add Participant Autocomplete -->
        <v-autocomplete
          v-model="newParticipant"
          :items="searchResults"
          color="blue-grey-lighten-2"
          item-title="fullname"
          item-value="id"
          label="Search for users..."
          hide-details
          chips
          closable-chips
          @input="searchUsers"
          :custom-filter="filterByMultipleFields"
          @update:model-value="addParticipant"
        >
          <template v-slot:chip="{ props, item }">
            <div v-bind="props" class="flex">
              <v-chip
                v-bind="props"
                class="flex justify-center items-center gap-1"
              >
                <template #prepend>
                  <user-avatar
                    :isOnline="item.raw?.is_online"
                    class="cursor-pointer"
                    size="xs"
                    :avatar="item.raw?.avatar"
                    :firstname="item.raw?.firstname"
                    :lastname="item.raw?.lastname"
                  />
                </template>

                {{ item.raw?.fullname }}
              </v-chip>
            </div>
          </template>

          <template v-slot:item="{ props, item }">

          <div v-bind="props" class="flex cursor-pointer p-1 hover:bg-sky-700">
              <user-avatar
                :isOnline="item.raw?.is_online"
                class="mr-3"
                size="md"
                :avatar="item.raw?.avatar"
                :firstname="item.raw?.firstname"
                :lastname="item.raw?.lastname"
              />

              <!-- User Info -->
              <div>
                <v-list-item-title class="font-medium">{{ item.raw.fullname }}</v-list-item-title>
                <v-list-item-subtitle >{{ item.raw.email }}</v-list-item-subtitle>
              </div>
            </div>
          </template>
        </v-autocomplete>
      </v-card-text>

      <!-- Action Buttons -->
      <v-card-actions class="justify-end">
        <v-btn color="primary" @click="closeDialog">Done</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';
import UserAvatar from '@/components/tools/Avatar.vue';
import filters from '@/tools/filters';
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';

// Props
const props = defineProps({
  isGroup: Boolean,
  participants: Array, // Current participants
  allUsers: Array,     // All users for adding as participants
  canDeleteParticipants: Boolean,
  canAddParticipants: Boolean,
  currentUser: Object,
  searchResults: Array
});

// Emits
const emit = defineEmits(['removeParticipant', 'addParticipant', 'searchUsers', 'close']);

// Dialog state
const dialog = ref(false);
const newParticipant = ref(null);

// Open and close dialog
const closeDialog = () => {
  dialog.value = false;
  emit('close');
};

// Remove a participant
const removeParticipant = (userId) => {
  emit('removeParticipant', userId);
};

// Add a participant
const addParticipant = () => {
  if (newParticipant.value) {
    emit('addParticipant', newParticipant.value);
    newParticipant.value = null;
  }
};

// Search users for adding
const searchUsers = (query) => {
  emit('searchUsers', query.target.value);
};

// Expose dialog methods to be controlled externally
defineExpose({ dialog });
</script>