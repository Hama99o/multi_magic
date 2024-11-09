<template>
  <div v-if="user">
    <v-row justify="center" class="p-0 m-0">
      <v-col cols="12" md="10" lg="8">
        <v-card class="rounded-lg overflow-hidden">
          <!-- Cover Image -->
          <div class="relative bg-background" :class="user.cover_photo ? '' : 'h-[225px] bg-info'">
            <div @click="user.cover_photo ? openCoverImagePreview() : (isCurrentUser ? opencoverPhotoDialog() : null)"  class="group cursor-pointer relative">
              <v-img
                class="bg-grey-lighten-2"
                max-height="225"
                :src="user.cover_photo"
                cover
              ></v-img>
              <div
                v-if="isCurrentUser"
                class="absolute right-0 top-0 border-2 border-white rounded-full flex h-8 w-8 items-center justify-center bg-background from-blue-500 to-green-500 text-white cursor-pointer shadow-lg transition-all duration-300 ease-in-out transform hover:scale-105 hover:from-blue-600 hover:to-green-600 hover:shadow-xl"
                @click.stop="opencoverPhotoDialog"
                >
                <Icon
                  icon="material-symbols:edit-outline-rounded"
                  class="h-4 w-4 transition-all duration-300 ease-in-out transform group-hover:scale-110"
                />
              </div>
            </div>

            <!-- Profile Picture -->
            <div class="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1/2 flex justify-center items-center">
              <div @click="user?.avatar ? openAvatarPreview() : (isCurrentUser ? openAvatarDialog() : null)"  class="group cursor-pointer relative">
                <avatar
                  :canShowOnline="!isCurrentUser"
                  :isOnline="user?.is_online"
                  :avatar="user?.avatar"
                  :firstname="user?.firstname"
                  :lastname="user?.lastname"
                  size="2xl"
                  class="rounded-full"
                />

                <div
                  v-if="isCurrentUser"
                  class="absolute right-0 bottom-0 border-2 border-white rounded-full flex h-8 w-8 items-center justify-center bg-background from-blue-500 to-green-500 text-white cursor-pointer shadow-lg transition-all duration-300 ease-in-out transform hover:scale-105 hover:from-blue-600 hover:to-green-600 hover:shadow-xl"
                  @click.stop="openAvatarDialog"
                  >
                  <Icon
                    icon="material-symbols:edit-outline-rounded"
                    class="h-4 w-4 transition-all duration-300 ease-in-out transform group-hover:scale-110"
                  />
                </div>
              </div>
            </div>
          </div>
          <!-- User Info -->
          <v-card-text class="text-center mt-16">
            <div class="text-2xl font-bold">{{ user.fullname }}</div>
            <div class="text-gray-600 mb-2">{{ `@${user.username}` }}</div>
            <div v-if="user.about" class="text-gray-500 mb-2">
              {{ user.about }}
            </div>

            <div v-if="user.email" class="text-gray-500 mb-2">
              {{ user.email  }}
            </div>

            <div v-if="user.birth_date" class="text-gray-500 mb-2">
              <v-icon class="text-primary mr-2">mdi-calendar</v-icon>
              Birth Day {{ user.birth_date ? filters.formatDate(user.birth_date, 'DD/MM/YYYY') : '' }}
            </div>
            <div class="text-gray-500">
              <v-icon class="text-primary mr-2">mdi-calendar</v-icon>
              Joined {{ filters.formatDate(user.created_at, 'DD/MM/YYYY') }}
            </div>
            <div class="mt-2">
              <span class="mr-4 cursor-pointer text-blue-600 hover:underline" @click="openDialog('following')">
                {{ user.following_count }} Following
              </span>
              <span class="cursor-pointer text-blue-600 hover:underline" @click="openDialog('followers')">
                {{ user.followers_count }} Followers
              </span>
            </div>
          </v-card-text>

          <!-- Send Message Button (Visible if not current user) -->
          <v-card-actions v-if="!isCurrentUser" class="justify-center mt-4">
            <v-btn
              elevation="2"
              class="px-6 py-3 text-lg font-bold tracking-wide uppercase text-white transition duration-300 ease-in-out transform bg-background from-blue-500 to-green-500 hover:from-blue-600 hover:to-green-600 shadow-lg hover:shadow-xl hover:scale-105 rounded-xl"
              @click="goToConversation"
            >
              <v-icon class="text-primary mr-2" left>mdi-message-outline</v-icon>
              Send Message
            </v-btn>
          </v-card-actions>

          <!-- Edit Profile Button -->
          <v-card-actions v-if="isCurrentUser" class="justify-center">
            <v-btn class="text-primary" outlined @click="openEditDialog">
              Edit Profile
            </v-btn>
          </v-card-actions>

          <div v-if="!isCurrentUser" class="p-4 flex gap-6">
            <div v-if="!user.is_blocking ">
              <v-btn v-if="!isFollowing" @click="followUser" color="primary">Follow</v-btn>
              <v-btn  v-else @click="unfollowUser" color="secondary">Unfollow</v-btn>
            </div>

            <v-btn v-if="!isBlocking" @click="blockUser" color="red">Block</v-btn>
            <v-btn v-else @click="unblockUser" color="grey">Unblock</v-btn>
          </div>
          <!-- Tabs -->
          <v-tabs
            v-model="activeTab"
            background-color="primary"
            dark
            centered
            align-tabs="center"
            class="mt-6"
          >
            <v-tab>Posts</v-tab>
            <v-tab>Replies</v-tab>
          </v-tabs>

          <!-- Tab Contents -->
          <v-tabs-items v-model="activeTab">
            <v-tab-item>
              <v-card flat>
                <v-card-text>Posts content goes here</v-card-text>
              </v-card>
            </v-tab-item>
            <v-tab-item>
              <v-card flat>
                <v-card-text>Replies content goes here</v-card-text>
              </v-card>
            </v-tab-item>
          </v-tabs-items>
        </v-card>
      </v-col>
    </v-row>
  </div>

  <image-preview
    v-if="user"
    ref="avatarPreviewDialog"
    :image="user.avatar"
    :isCurrentUser="isCurrentUser"
    @delete-avatar="deleteAvatar"
    @open-edit-image-dialog="avatarDialog.dialog = true"
  />

  <image-preview
    v-if="user"
    ref="coverImagePreviewDialog"
    :image="user.cover_photo"
    :isCurrentUser="isCurrentUser"
    @delete-avatar="deleteAvatar('cover_photo')"
    @open-edit-image-dialog="coverPhotoDialog.dialog = true"
  />

  <edit v-if="isCurrentUser" ref="editUserDialog"/>

  <!-- Edit Avatar Dialog -->
  <edit-image
    v-if="isCurrentUser && user"
    ref="avatarDialog"
    :image="user.avatar"
    @delete-avatar="deleteAvatar"
    image-type="photo"
    @upload-image="uploadImage"
  />

  <edit-image
    v-if="isCurrentUser && user"
    ref="coverPhotoDialog"
    :image="user.cover_photo"
    @delete-avatar="deleteAvatar('cover_photo')"
    image-type="cover_photo"
    @upload-image="uploadImage"
  />

  <!-- Following/Followers Dialog -->
  <follow-list
    ref="dialogVisible"
    :dialogTitle="dialogTitle"
    :loading="loading"
    :userList="userList"
    @goToProfile="goToProfile($event)"
  />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';
import filters from "@/tools/filters";
import Edit from "@/components/users/Edit.vue";
import Avatar from "@/components/tools/Avatar.vue";
import EditImage from "@/components/users/EditImage.vue";
import ImagePreview from "@/components/users/ImagePreview.vue";
import {Icon} from "@iconify/vue";
import { showToast } from '@/utils/showToast';
import { useConversationStore } from '@/stores/conversation.store';
import { useFollowStore } from '@/stores/follow.store';
import { useBlockStore } from '@/stores/block.store';
import FollowList from "@/components/users/FollowList.vue";

const activeTab = ref(0);

const route = useRoute();

const { createFollow, deleteFollow } = useFollowStore();
const { createBlock, deleteBlock } = useBlockStore();

const { createConversation } = useConversationStore();

// Fetch following and followers from the user store
const { fetchUser, updateUser, deleteUserAvatar, fetchFollowing, fetchFollowers, resetStates } = useUserStore();
const { user, currentUser } = storeToRefs(useUserStore());

const editUserDialog = ref(false);
const avatarDialog = ref(false)
const coverPhotoDialog = ref(false)
const avatarPreviewDialog = ref(false);
const coverImagePreviewDialog = ref(false);
const coverPhoto = ref(null);

const opencoverPhotoDialog = () => {
  coverPhotoDialog.value.dialog = true;
};

const isCurrentUser = computed(() => {
  return route.params.id == currentUser.value.id
})

const isFollowing = computed(() => {
  return user.value.is_following
})

const isBlocking = computed(() => {
  return user.value.is_blocking
})

const openAvatarDialog = () => {
  avatarDialog.value.dialog = true;
};

onMounted(async () => {
  try {
    await fetchUser(route.params.id);
    fetchFollowing(route.params.id)
    fetchFollowers(route.params.id)
    coverPhoto.value = user.value.cover_photo
  } catch (error) {
    console.log(error);
  }
});

const openEditDialog = () => {
  editUserDialog.value.editDialog = true;
};

const uploadImage = async (formData, image, imageType) => {
  if (formData) {
    try {
      const res = await updateUser(user.value.id, formData);
      // Update the local user avatar
      if (imageType == 'photo') {
        user.value.avatar = image
        user.value.avatar = res.user.avatar
      } else{
        user.value.cover_photo = image
        user.value.cover_photo = res.user.cover_photo
      }

      closeAllDialogs();
      showToast(`image uploaded successfully`, 'success');
    } catch (error) {
      console.log('Upload failed:', error);
      showToast(`Upload failed`, 'error');

    }
  }
};

const deleteAvatar = (imageType = 'photo') => {
  deleteUserAvatar(user.value.id, imageType)
  closeAllDialogs()
  user.value.avatar = null; // Set avatar to null or default image after deletion
  showToast(`image deleted successfully`, 'success');
};

const closeAllDialogs = () => {
  avatarPreviewDialog.value.dialog = false;
  coverImagePreviewDialog.value = false
  avatarDialog.value.dialog = false;
};

const openAvatarPreview = () => {
  avatarPreviewDialog.value.dialog = true;
};

const openCoverImagePreview = () => {
  coverImagePreviewDialog.value.dialog = true;
};

import { useRouter } from 'vue-router';

const router = useRouter();

const goToConversation = async() => {
  const res = await createConversation(user.value.id);
  router.push({ name: 'conversations', query: { conversation_id: res?.conversation?.id } });
};

const followUser = async () => {
  await createFollow(user.value.id)
  user.value.is_following = true
  user.value.followers_count +=1
};

const unfollowUser = async () => {
  await deleteFollow(user.value.id);
  user.value.is_following = false
  user.value.followers_count -=1
};

const blockUser = async () => {
  await createBlock(user.value.id)
  user.value.is_blocking = true
  user.value.is_following = false
};

const unblockUser = async () => {
  await deleteBlock(user.value.id);
  user.value.is_blocking = false
};

// Define state variables
const dialogVisible = ref(false);
const dialogTitle = ref('');
const userList = ref([]);
const loading = ref(false);

// Function to open the dialog and fetch users
const openDialog = async (type) => {
  dialogVisible.value.dialogVisible = true;
  dialogTitle.value = type === 'following' ? 'Following' : 'Followers';
  loading.value = true;

  if (type === 'following') {
    userList.value = await fetchFollowing(route.params.id);
  } else {
    userList.value = await fetchFollowers(route.params.id);
  }

  loading.value = false;
};

// Function to close the dialog
const closeDialog = () => {
  dialogVisible.value.dialogVisible = false;
};

const goToProfile = async(userId) => {
  router.push({ name: 'user', params: { id: userId } })
  await fetchUser(userId);
  closeDialog()
}
</script>
