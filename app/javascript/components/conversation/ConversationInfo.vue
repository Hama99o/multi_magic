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
              class="flex flex-col sm:flex-row items-start sm:items-center justify-between px-4 py-3 hover:bg-sky-100 rounded-lg transition-colors duration-200"
            >
              <!-- User Info Section -->
              <div class="flex items-center w-full sm:w-auto mb-2 sm:mb-0">
                <AvatarWithUserInfo
                  class="cursor-pointer mr-3"
                  size="md"
                  :user="participant?.user"
                  withFullname
                  @update-user="participant.user.is_following = $event"
                >
                  <template #fullname>
                    <div>
                      <v-list-item-title class="text-base font-medium">
                        {{ participant.user.fullname }}
                      </v-list-item-title>
                      <v-list-item-subtitle class="text-xs text-gray-500">
                        {{ participant.user.email }}
                      </v-list-item-subtitle>
                    </div>
                  </template>
                </AvatarWithUserInfo>

                <v-chip
                  v-if="participant.is_admin"
                  color="primary"
                  size="x-small"
                  class="ml-2"
                >
                  Admin
                </v-chip>
              </div>

              <div class="flex items-center justify-end w-full sm:w-auto mt-2 sm:mt-0">
                <!-- Admin Toggle -->
                <v-switch
                  v-model="participant.is_admin"
                  color="primary"
                  hide-details
                  density="compact"
                  class="mr-2"
                  @change="toggleAdminStatus(participant)"
                >
                  <template #label>
                    <span class="sr-only">Toggle admin status for {{ participant.user.fullname }}</span>
                  </template>
                </v-switch>

                <!-- Remove Button for Group Admins -->
                <v-btn
                  icon
                  color="red"
                  size="small"
                  @click="removeParticipant(participant.user.id)"
                  :aria-label="`Remove ${participant.user.fullname}`"
                >
                  <v-icon>mdi-delete</v-icon>
                </v-btn>
              </div>
            </v-list-item>
          </v-list-item-group>
        </v-list>

        <!-- Add Participant Autocomplete -->
        <v-autocomplete
          v-if="canAddParticipants"
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
          @update:model-value="addOrUpdateParticipant"
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
            <div v-bind="props" class="flex cursor-pointer p-1 hover:bg-sky-100">
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
import AvatarWithUserInfo from '@/components/tools/AvatarWithUserInfo.vue';

// Props
const props = defineProps({
  isGroup: Boolean,
  participants: Array, // Current participants
  allUsers: Array,     // All users for adding as participants
  canDeleteParticipants: Boolean,
  canAddParticipants: Boolean,
  canManageAdmins: Boolean,
  currentUser: Object,
  searchResults: Array
});

// Emits
const emit = defineEmits([
  'removeParticipant',
  'addOrUpdateParticipant',
  'searchUsers',
  'close'
]);

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
const addOrUpdateParticipant = () => {
  if (newParticipant.value) {
    emit('addOrUpdateParticipant', {
      userId: newParticipant.value,
      isAdmin: false
    });
    newParticipant.value = null;
  }
};

// Search users for adding
const searchUsers = (query) => {
  emit('searchUsers', query.target.value);
};

// Toggle admin status
const toggleAdminStatus = (participant) => {
  emit('addOrUpdateParticipant', {
    userId: participant.user.id,
    isAdmin: participant.is_admin
  });
};

// Filter function for autocomplete
const filterByMultipleFields = (item, queryText, itemText) => {
  const searchText = queryText.toLowerCase();
  return (
    item.raw.fullname.toLowerCase().indexOf(searchText) > -1 ||
    item.raw.email.toLowerCase().indexOf(searchText) > -1
  );
};

// Expose dialog methods to be controlled externally
defineExpose({ dialog });
</script>