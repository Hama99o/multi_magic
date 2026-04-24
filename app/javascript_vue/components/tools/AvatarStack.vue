<template>
  <div class="relative" :style="{ width: `${totalWidth}px`, height: '40px' }">
    <div v-for="(user, index) in users" :key="index">
      <user-avatar
        class="cursor-pointer rounded-full"
        :size="size"
        @click.stop="goToUserShow(user.id)"
        :avatar="user?.avatar"
        vAvatarClass="v-avatar"
        :style="{
          position: 'absolute',
          right: `${(users.length - index - 1) * 18}px`,
          zIndex: users.length - index,
        }"
        :firstname="user?.lastname"
        :lastname="user?.firstname"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import UserAvatar from '@/components/tools/Avatar.vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const props = defineProps({
  users: {
    type: Array,
    default: () => [
      {
        id: 1,
        avatar:
          'https://thefrugalchicken.com/wp-content/uploads/2023/04/What-do-baby-ducks-eat-min.jpg?height=40&width=40',
        alt: 'User 1',
      },
      {
        id: 2,
        avatar:
          'https://thefrugalchicken.com/wp-content/uploads/2023/04/What-do-baby-ducks-eat-min.jpg?height=40&width=40',
        alt: 'User 2',
      },
      {
        id: 3,
        avatar:
          'https://thefrugalchicken.com/wp-content/uploads/2023/04/What-do-baby-ducks-eat-min.jpg?height=40&width=40',
        alt: 'User 3',
      },
      {
        id: 5,
        avatar:
          'https://thepointsguy.global.ssl.fastly.net/us/originals/2022/07/2Photo-Jul-01-11-14-04-AM.jpg?height=40&width=40',
        alt: 'User 5',
      },
      {
        id: 4,
        firstname: 'Hama',
        lastname: 'safi',
        avatar:
          'https://thefrugalchickedsfn.com/wp-content/uploads/2023/04/What-do-baby-ducks-eat-min.jpg?height=40&width=40',
        alt: 'User 4',
      },
    ],
  },
  size: { type: String, default: 'lg' },
});

const totalWidth = computed(() => {
  return props.users.length > 1 ? 40 + (props.users.length - 1) * 20 : 40;
});

const goToUserShow = (id) => {
  router.push({ name: 'user', params: { id } })
}
</script>

<style>
.v-avatar {
  transition: transform 0.2s ease-in-out;
}
.v-avatar:hover {
  transform: translateY(-4px);
}
</style>
