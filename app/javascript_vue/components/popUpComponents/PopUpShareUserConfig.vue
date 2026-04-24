<template>
  <v-dialog max-width="800" v-model="data.open">
    <template #default>
      <div class="w-full flex flex-col p-6 gap-8 bg-surface">
        <!-- Icon and text -->

        <div class="flex justify-between  align-center mb-5">
          <p></p>
          <p
            v-for="text in title"
            :key="text"
            class="text-center font-medium text-xl"
          >
            {{ $t(text) }}
          </p>
          <v-icon
            class="text-primary text-xl hover:bg-red-200 p-3"
            icon="mdi mdi-close"
            @click="closePopUp"
          />
        </div>

        <div v-for="user in data?.note.shared_users" :key="user.id" class="hover:bg-grey">
          <div class="flex justify-between m-2">

            <p v-if="!isMobile">
              <user-avatar
                canShowOnline
                :isOnline="user?.is_online"
                class="mr-1"
                size="sm"
                :avatar="user?.avatar"
                :firstname="user?.lastname"
                :lastname="user?.firstname"
              />

              {{ user.fullname }}
            </p>

            <p>
              {{ user.email }}
            </p>


            <v-menu>
              <template v-slot:activator="{ props }">
                <p class="flex item-center cursor-pointer" v-bind="props">
                  {{ user.note_role }} <span class="ml-2 mdi mdi-menu-down-outline"></span>
                </p>

              </template>

              <v-list>
                <v-list-item v-for="(item, index) in roles" :key="index" :value="index" class="hover:bg-grey" >
                  <v-list-item-title @click="updateUserRights(item, user)">{{ item.title }}</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>

            <v-icon
              class="text-primary text-xl hover:bg-red-200 p-3 mx-5"
              icon="mdi mdi-close"
              @click="removeCollaborator(user)"
            />
           </div>
        </div>
      </div>
    </template>
  </v-dialog>
</template>

<script setup>
import { storeToRefs } from "pinia";
import { usePopUpStore } from "@/stores/pop-up.store";
import PopUpSkeleton from "./PopUpSkeleton.vue";
import UserAvatar from '@/components/tools/Avatar.vue';
import { useNoteStore } from '@/stores/note_app/note.store';
import { ref } from 'vue';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());
const { inviteUserToggle, updateSharedUserRights } = useNoteStore();
const { data } = storeToRefs(usePopUpStore());
const { closePopUp } = usePopUpStore();

const roles = ref([
        { title: 'viewer' },
        { title: 'contributor' },
        { title: 'administrator' }
      ])

const title = data.value.title.split("<br/>")
const subtitle = data.value.subtitle?.split("<br/>")
const removeCollaborator = async(user) => {
  try {
    const params = {
      email: user?.email,
      user_action: 'remove'
    }
    await inviteUserToggle(data.value?.note?.id, params)
    data.value.note.shared_users = data.value?.note?.shared_users.filter((shared_user) => shared_user.id !== user.id)
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
}

const updateUserRights = async(role, user) => {
  try {
    const params = {
      user_id: user?.id,
      role: role.title
    }
    await updateSharedUserRights(data.value?.note?.id, params)
    data.value?.note?.shared_users.forEach((shared_user) => {
      if (shared_user.id === user.id) {
        shared_user.role =  null
      }
    })
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
}
</script>
