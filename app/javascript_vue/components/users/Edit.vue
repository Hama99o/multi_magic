<template>
  <!-- Edit Profile Dialog -->
  <v-dialog v-model="editDialog" max-width="800px">
    <v-card>
      <v-card-actions>
        <v-btn @click="editDialog = false" icon="mdi mdi-window-close"></v-btn>
      </v-card-actions>

      <v-card-title class="text-center">Edit Profile</v-card-title>
      <v-card-text class="!py-0">
        <v-form ref="editForm" v-model="valid">
          <div class="flex flex-wrap gap-2">
            <v-text-field
              v-model="form.firstname"
              label="First Name"
              class="w-[49%]"
              :rules="[v => !!v || 'Full name is required']"
              required
            />

            <v-text-field
              v-model="form.lastname"
              label="last Name"
              :rules="[v => !!v || 'Full name is required']"
              required
              class="w-[49%]"
            />
          </div>
          <div class="flex flex-wrap gap-2">
            <v-textarea
              v-model="form.about"
              label="About"
              row-height="20"
              rows="2"
              variant="filled"
              auto-grow
            ></v-textarea>
          </div>
          <div class="flex flex-wrap gap-2">
            <v-text-field
              v-model="form.username"
              label="User Name"
              class="w-[100%] md:w-[65%]"
              :rules="[v => !!v || 'Full name is required']"
              required
            />

            <!-- Loan Type Filter -->
            <v-select
              v-model="form.gender"
              :items="genders"
              label="gender"
              item-value="key"
              class="w-[15%]"
            />

            <date-picker
              ref="dateModal"
              :date-value="form.birth_date"
              @save="setDueDate"
            >
              <template #activator="{ props }">
                <v-text-field
                  @click="dateModal.dialog = true"
                  v-model="formattedDate"
                  label="Birth Date"
                  readonly
                  v-bind="props"
                  outlined
                  required
                  class="w-[15%]"
                ></v-text-field>
              </template>
            </date-picker>
          </div>

          <div class="flex flex-wrap gap-2">
            <!-- Country Code Select with Flags -->
            <v-autocomplete
              v-model="form.country_code"
              :items="countryCodes"
              label="Country Code"
              item-title="label"
              item-value="code"
              class="w-[100%] md:!w-[25%]"
              dense
              outlined
              ref="autocomplete"
            >
              <template #item="{ item }">
                <div class="flex items-center cursor-pointer hover:grey text-nowrap hover:bg-sky-700" @click="form.country_code = item.raw.code, autocomplete?.blur()">
                  <span class="mr-1 cursor-pointer">{{ item.raw.flag }}</span> {{ item.raw.label }}
                </div>
              </template>
              <template #selection="{ item }">
                <div class="flex items-center  text-nowrap ">
                  <span class="mr-1">{{ item.raw.flag }}</span> {{ item.raw.label }}
                </div>
              </template>
            </v-autocomplete>

            <!-- Phone Number Input -->
            <v-text-field
              v-model="form.phone_number"
              label="Phone Number"
              type="tel"
              class="w-[69%]"
              outlined
              dense
              required
            />
          </div>

          <a
            class="text-blue-500 text-sm inline-block cursor-pointer"
            @click.prevent="openPasswordDialog"
          >
            Password and Security
          </a>
          <!-- <v-text-field
            v-model="form.address"
            label="Address"
          /> -->
        </v-form>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn color="secondary" text @click="closeEditDialog">Cancel</v-btn>
        <v-btn color="primary" @click="saveProfile" :disabled="!valid">Save</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <!-- Password and Security Dialog -->
  <v-dialog v-model="passwordDialog" max-width="400px">
    <v-card>
      <v-card-actions>
        <v-btn @click="openEditUserDialog"icon="mdi mdi-keyboard-backspace"></v-btn>
        <v-spacer></v-spacer>
        <v-btn  @click="passwordDialog = false" icon="mdi mdi-window-close"></v-btn>
      </v-card-actions>
      <v-card-title class="text-h5 font-semibold">
        Change password
      </v-card-title>
      <v-card-subtitle class="text-wrap flex justify-center items-center">
        Your password must be at least 6 characters and should include a combination of numbers, letters, and special characters (!@$%^&*).
      </v-card-subtitle>
      <v-card-text>
        <v-form ref="passwordForm" v-model="passwordValid">
          <v-text-field
            v-model="passwordFormData.current_password"
            label="Current password"
            :type="showCurrentPassword ? 'text' : 'password'"
            :append-inner-icon="showCurrentPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="togglePasswordVisibility('current')"
            :rules="[v => !!v || 'Current password is required']"
            required
            dense
            outlined
            class="mb-2"
            :class="{'text-gray-400': !passwordFormData.current_password}"
          />

          <!-- New Password Field -->
          <v-text-field
            v-model="passwordFormData.password"
            label="New password"
            :type="showNewPassword ? 'text' : 'password'"
            :append-inner-icon="showNewPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="togglePasswordVisibility('new')"
            :rules="[v => !!v || 'New password is required']"
            required
            dense
            outlined
            class="mb-2"
            :class="{'text-gray-400': !passwordFormData.password}"
          />

          <!-- Confirm New Password Field -->
          <v-text-field
            v-model="passwordFormData.password_confirmation"
            label="Re-type new password"
            :type="showConfirmPassword ? 'text' : 'password'"
            :append-inner-icon="showConfirmPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="togglePasswordVisibility('confirm')"
            :rules="[v => v === passwordFormData.password || 'Passwords do not match']"
            required
            dense
            outlined
            :class="{'text-gray-400': !passwordFormData.password_confirmation}"
          />

          <a
            class="mb-4 text-blue-500 text-sm inline-block cursor-pointer"
            @click.prevent="openResetPasswordDialog"
          >
            Forgot your password?
          </a>
        </v-form>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn text @click="closePasswordDialog">Cancel</v-btn>
        <v-btn :disabled="!passwordValid" @click="changePasswordMethod">Change password</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>

  <!-- Reset Password Dialog -->
  <v-dialog v-model="resetPasswordDialog" max-width="300px">
    <v-card>
      <v-card-actions>
        <v-btn @click="backToChangePassword"icon="mdi mdi-keyboard-backspace"></v-btn>
        <v-spacer></v-spacer>
        <v-btn  @click="resetPasswordDialog = false" icon="mdi mdi-window-close"></v-btn>
      </v-card-actions>
      <v-card-title class="text-h5 font-semibold justify-center items-center flex">
        Reset your password
      </v-card-title>
      <v-card-text class="flex flex-col gap-3 justify-center items-center">
        <v-avatar size="64">
          <img :src="user.avatar" alt="User Avatar">
        </v-avatar>
        {{  hideEmail(user.email)}}
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn text color="gray" @click="closeResetPasswordDialog">Cancle</v-btn>
        <v-btn @click="sendResetEmail" class="text-white bg-blue-600 hover:bg-blue-700">Send</v-btn>
        <v-spacer></v-spacer>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useUserStore } from '@/stores/user.store';
import { useMobileStore } from "@/stores/mobile";
import DatePicker from '@/components/tools/DatePicker.vue';
import moment from "moment";
import { showToast } from '@/utils/showToast';

const { isMobile, isMdScreen } = storeToRefs(useMobileStore());

const route = useRoute();

const { forgotPassword, updateUser, changePassword } = useUserStore();
const { user } = storeToRefs(useUserStore());

const editDialog = ref(false);
const dateModal = ref(false);
const valid = ref(false);
const autocomplete = ref(false);
const showCurrentPassword = ref(false);
const showNewPassword = ref(false);
const showConfirmPassword = ref(false);

const form = ref({
  about: '',
  countryCode: '',
  username: '',
  firstname: '',
  lastname: '',
  gender: '',
  phone_number: '',
  address: '',
  country_code: '+33',
  birth_date: '',
});

onMounted(async () => {
  try {
    form.value = {
      about: user.value?.about || '',
      firstname: user.value?.firstname || '',
      lastname: user.value?.lastname || '',
      username: user.value?.username || '',
      gender: user.value?.gender || '',
      phone_number: user.value?.phone_number || '',
      address: user.value?.address || '',
      birth_date: user.value?.birth_date || '',
      country_code: user.value?.country_code || '+33',
    };
  } catch (error) {
    console.log(error);
  }
});

const closeEditDialog = () => {
  editDialog.value = false;
  resetUser()
};

const saveProfile = async() => {
  form.value.birth_date = formattedDate.value
  if (valid.value) {
    try {
      await updateUser(route.params.id, form.value)
      closeEditDialog();
      showToast(`profile saved successfully`, 'success');
    } catch (error) {
      if (error.username) {
        showToast(`Username ${error.username}`, 'error');
      } else {
        showToast(`Saved failed`, 'error');
      }
    }
  }
};

const hideEmail = (email) => {
  if (!email) return null
  return email.replace(/(.{1})(.*)(?=@)/,
    function(gp1, gp2, gp3) {
      for(let i = 0; i < gp3.length; i++) {
        gp2+= "*";
      } return gp2;
    });
};
// Data for the password dialog
const passwordDialog = ref(false);
const passwordValid = ref(false);

const passwordFormData = ref({
  current_password: '',
  password: '',
  password_confirmation: ''
});

// Reset Password Dialog state
const resetPasswordDialog = ref(false);
const selectedOption = ref(null);

// Function to send the reset email
const sendResetEmail = () => {
  forgotPassword({ email: user.value.email })
  resetPasswordDialog.value = false;
  passwordDialog.value = true
};

const backToChangePassword = () => {
  resetPasswordDialog.value = false
  passwordDialog.value = true
}

const openEditUserDialog = () => {
  closePasswordDialog()
}

// Function to open the reset password dialog
const openResetPasswordDialog = () => {
  resetPasswordDialog.value = true;
  passwordDialog.value = false
};

// Function to close the reset password dialog
const closeResetPasswordDialog = () => {
  resetPasswordDialog.value = false;
  passwordDialog.value = true
};

// Function to toggle password visibility
const togglePasswordVisibility = (field) => {
  if (field === 'current') {
    showCurrentPassword.value = !showCurrentPassword.value;
  } else if (field === 'new') {
    showNewPassword.value = !showNewPassword.value;
  } else if (field === 'confirm') {
    showConfirmPassword.value = !showConfirmPassword.value;
  }
};

const openPasswordDialog = () => {
  passwordDialog.value = true;
  editDialog.value = false;
};

const closePasswordDialog = () => {
  passwordDialog.value = false;
  editDialog.value = true;
  passwordFormData.value = {
    current_password: '',
    password: '',
    password_confirmation: ''
  };
};

const changePasswordMethod = async () => {
  if (passwordValid.value) {
    try {
      // Send password change request to server
      await changePassword(user.value.id, passwordFormData.value);
      closePasswordDialog();
      showToast(`password changed successfully`, 'success');
    } catch (error) {
      console.error('Password change failed:', error);
      showToast(`Password change failed`, 'error');
    }
  }
};

watch(editDialog, (newValue, oldValue) => {
  if (newValue) {
    form.value = {
      about: user.value?.about || '',
      username: user.value?.username || '',
      firstname: user.value?.firstname || '',
      lastname: user.value?.lastname || '',
      gender: user.value?.gender || '',
      phone_number: user.value?.phone_number || '',
      address: user.value?.address || '',
      birth_date: user.value?.birth_date || '',
      country_code: user.value?.country_code || '+33',
    }
  }
})

watch(user, (newValue, oldValue) => {
  if (newValue) {
    form.value = {
      about: user.value?.about || '',
      username: user.value?.username || '',
      firstname: user.value?.firstname || '',
      lastname: user.value?.lastname || '',
      gender: user.value?.gender || '',
      phone_number: user.value?.phone_number || '',
      address: user.value?.address || '',
      birth_date: user.value?.birth_date || '',
      country_code: user.value?.country_code || '+33',
    }
  }
})

const genders = [
  { title: 'Male', key: 'male' },
  { title: 'Female', key: 'female' },
  { title: 'Other', key: 'other' },
]

const formattedDate = computed(() => {
  return form.value.birth_date ? moment(form.value.birth_date).format('YYYY-MM-DD') : '';
});

const setDueDate = (e) => {
  form.value.birth_date = e
};

const countryCodes = ref([
  { flag: '🇦🇫', label: 'Afghanistan (+93)', code: '+93' },
  { flag: '🇦🇱', label: 'Albania (+355)', code: '+355' },
  { flag: '🇩🇿', label: 'Algeria (+213)', code: '+213' },
  { flag: '🇦🇸', label: 'American Samoa (+1-684)', code: '+1-684' },
  { flag: '🇦🇩', label: 'Andorra (+376)', code: '+376' },
  { flag: '🇦🇴', label: 'Angola (+244)', code: '+244' },
  { flag: '🇦🇮', label: 'Anguilla (+1-264)', code: '+1-264' },
  { flag: '🇦🇶', label: 'Antarctica', code: '' },
  { flag: '🇦🇬', label: 'Antigua and Barbuda (+1-268)', code: '+1-268' },
  { flag: '🇦🇷', label: 'Argentina (+54)', code: '+54' },
  { flag: '🇦🇲', label: 'Armenia (+374)', code: '+374' },
  { flag: '🇦🇼', label: 'Aruba (+297)', code: '+297' },
  { flag: '🇦🇺', label: 'Australia (+61)', code: '+61' },
  { flag: '🇦🇹', label: 'Austria (+43)', code: '+43' },
  { flag: '🇦🇿', label: 'Azerbaijan (+994)', code: '+994' },
  { flag: '🇧🇸', label: 'Bahamas (+1-242)', code: '+1-242' },
  { flag: '🇧🇭', label: 'Bahrain (+973)', code: '+973' },
  { flag: '🇧🇩', label: 'Bangladesh (+880)', code: '+880' },
  { flag: '🇧🇧', label: 'Barbados (+1-246)', code: '+1-246' },
  { flag: '🇧🇾', label: 'Belarus (+375)', code: '+375' },
  { flag: '🇧🇪', label: 'Belgium (+32)', code: '+32' },
  { flag: '🇧🇿', label: 'Belize (+501)', code: '+501' },
  { flag: '🇧🇯', label: 'Benin (+229)', code: '+229' },
  { flag: '🇧🇲', label: 'Bermuda (+1-441)', code: '+1-441' },
  { flag: '🇧🇹', label: 'Bhutan (+975)', code: '+975' },
  { flag: '🇧🇴', label: 'Bolivia (+591)', code: '+591' },
  { flag: '🇧🇦', label: 'Bosnia and Herzegovina (+387)', code: '+387' },
  { flag: '🇧🇼', label: 'Botswana (+267)', code: '+267' },
  { flag: '🇧🇷', label: 'Brazil (+55)', code: '+55' },
  { flag: '🇮🇴', label: 'British Indian Ocean Territory (+246)', code: '+246' },
  { flag: '🇻🇬', label: 'British Virgin Islands (+1-284)', code: '+1-284' },
  { flag: '🇧🇳', label: 'Brunei (+673)', code: '+673' },
  { flag: '🇧🇬', label: 'Bulgaria (+359)', code: '+359' },
  { flag: '🇧🇫', label: 'Burkina Faso (+226)', code: '+226' },
  { flag: '🇧🇮', label: 'Burundi (+257)', code: '+257' },
  { flag: '🇰🇭', label: 'Cambodia (+855)', code: '+855' },
  { flag: '🇨🇲', label: 'Cameroon (+237)', code: '+237' },
  { flag: '🇨🇦', label: 'Canada (+1)', code: '+1' },
  { flag: '🇨🇻', label: 'Cape Verde (+238)', code: '+238' },
  { flag: '🇰🇾', label: 'Cayman Islands (+1-345)', code: '+1-345' },
  { flag: '🇨🇫', label: 'Central African Republic (+236)', code: '+236' },
  { flag: '🇹🇩', label: 'Chad (+235)', code: '+235' },
  { flag: '🇨🇱', label: 'Chile (+56)', code: '+56' },
  { flag: '🇨🇳', label: 'China (+86)', code: '+86' },
  { flag: '🇨🇽', label: 'Christmas Island (+61)', code: '+61' },
  { flag: '🇨🇨', label: 'Cocos (Keeling) Islands (+61)', code: '+61' },
  { flag: '🇨🇴', label: 'Colombia (+57)', code: '+57' },
  { flag: '🇰🇲', label: 'Comoros (+269)', code: '+269' },
  { flag: '🇨🇬', label: 'Congo (+242)', code: '+242' },
  { flag: '🇨🇩', label: 'Congo (DRC) (+243)', code: '+243' },
  { flag: '🇨🇰', label: 'Cook Islands (+682)', code: '+682' },
  { flag: '🇨🇷', label: 'Costa Rica (+506)', code: '+506' },
  { flag: '🇭🇷', label: 'Croatia (+385)', code: '+385' },
  { flag: '🇨🇺', label: 'Cuba (+53)', code: '+53' },
  { flag: '🇨🇼', label: 'Curaçao (+599)', code: '+599' },
  { flag: '🇨🇾', label: 'Cyprus (+357)', code: '+357' },
  { flag: '🇨🇿', label: 'Czech Republic (+420)', code: '+420' },
  { flag: '🇩🇰', label: 'Denmark (+45)', code: '+45' },
  { flag: '🇩🇯', label: 'Djibouti (+253)', code: '+253' },
  { flag: '🇩🇲', label: 'Dominica (+1-767)', code: '+1-767' },
  { flag: '🇩🇴', label: 'Dominican Republic (+1-809, +1-829, +1-849)', code: '+1-809' },
  { flag: '🇪🇨', label: 'Ecuador (+593)', code: '+593' },
  { flag: '🇪🇬', label: 'Egypt (+20)', code: '+20' },
  { flag: '🇸🇻', label: 'El Salvador (+503)', code: '+503' },
  { flag: '🇬🇶', label: 'Equatorial Guinea (+240)', code: '+240' },
  { flag: '🇪🇷', label: 'Eritrea (+291)', code: '+291' },
  { flag: '🇪🇪', label: 'Estonia (+372)', code: '+372' },
  { flag: '🇸🇿', label: 'Eswatini (+268)', code: '+268' },
  { flag: '🇪🇹', label: 'Ethiopia (+251)', code: '+251' },
  { flag: '🇫🇰', label: 'Falkland Islands (+500)', code: '+500' },
  { flag: '🇫🇴', label: 'Faroe Islands (+298)', code: '+298' },
  { flag: '🇫🇯', label: 'Fiji (+679)', code: '+679' },
  { flag: '🇫🇮', label: 'Finland (+358)', code: '+358' },
  { flag: '🇫🇷', label: 'France (+33)', code: '+33' },
  { flag: '🇬🇫', label: 'French Guiana (+594)', code: '+594' },
  { flag: '🇵🇫', label: 'French Polynesia (+689)', code: '+689' },
  { flag: '🇹🇫', label: 'French Southern Territories', code: '' },
  { flag: '🇬🇦', label: 'Gabon (+241)', code: '+241' },
  { flag: '🇬🇲', label: 'Gambia (+220)', code: '+220' },
  { flag: '🇬🇪', label: 'Georgia (+995)', code: '+995' },
  { flag: '🇩🇪', label: 'Germany (+49)', code: '+49' },
  { flag: '🇬🇭', label: 'Ghana (+233)', code: '+233' },
  { flag: '🇬🇮', label: 'Gibraltar (+350)', code: '+350' },
  { flag: '🇬🇷', label: 'Greece (+30)', code: '+30' },
  { flag: '🇬🇱', label: 'Greenland (+299)', code: '+299' },
  { flag: '🇬🇩', label: 'Grenada (+1-473)', code: '+1-473' },
  { flag: '🇬🇵', label: 'Guadeloupe (+590)', code: '+590' },
  { flag: '🇬🇺', label: 'Guam (+1-671)', code: '+1-671' },
  { flag: '🇬🇹', label: 'Guatemala (+502)', code: '+502' },
  { flag: '🇬🇬', label: 'Guernsey (+44)', code: '+44' },
  { flag: '🇬🇳', label: 'Guinea (+224)', code: '+224' },
  { flag: '🇬🇼', label: 'Guinea-Bissau (+245)', code: '+245' },
  { flag: '🇬🇾', label: 'Guyana (+592)', code: '+592' },
  { flag: '🇭🇹', label: 'Haiti (+509)', code: '+509' },
  { flag: '🇭🇳', label: 'Honduras (+504)', code: '+504' },
  { flag: '🇭🇰', label: 'Hong Kong (+852)', code: '+852' },
  { flag: '🇭🇺', label: 'Hungary (+36)', code: '+36' },
  { flag: '🇮🇸', label: 'Iceland (+354)', code: '+354' },
  { flag: '🇮🇳', label: 'India (+91)', code: '+91' },
  { flag: '🇮🇩', label: 'Indonesia (+62)', code: '+62' },
  { flag: '🇮🇷', label: 'Iran (+98)', code: '+98' },
  { flag: '🇮🇶', label: 'Iraq (+964)', code: '+964' },
  { flag: '🇮🇪', label: 'Ireland (+353)', code: '+353' },
  { flag: '🇮🇲', label: 'Isle of Man (+44)', code: '+44' },
  { flag: '🇮🇱', label: 'Israel (+972)', code: '+972' },
  { flag: '🇮🇹', label: 'Italy (+39)', code: '+39' },
  { flag: '🇯🇲', label: 'Jamaica (+1-876)', code: '+1-876' },
  { flag: '🇯🇵', label: 'Japan (+81)', code: '+81' },
  { flag: '🇯🇪', label: 'Jersey (+44)', code: '+44' },
  { flag: '🇯🇴', label: 'Jordan (+962)', code: '+962' },
  { flag: '🇰🇿', label: 'Kazakhstan (+7)', code: '+7' },
  { flag: '🇰🇪', label: 'Kenya (+254)', code: '+254' },
  { flag: '🇰🇮', label: 'Kiribati (+686)', code: '+686' },
  { flag: '🇰🇵', label: 'Korea (North) (+850)', code: '+850' },
  { flag: '🇰🇷', label: 'Korea (South) (+82)', code: '+82' },
  { flag: '🇽🇰', label: 'Kosovo (+383)', code: '+383' },
  { flag: '🇰🇼', label: 'Kuwait (+965)', code: '+965' },
  { flag: '🇰🇬', label: 'Kyrgyzstan (+996)', code: '+996' },
  { flag: '🇱🇦', label: 'Laos (+856)', code: '+856' },
  { flag: '🇱🇻', label: 'Latvia (+371)', code: '+371' },
  { flag: '🇱🇧', label: 'Lebanon (+961)', code: '+961' },
  { flag: '🇱🇸', label: 'Lesotho (+266)', code: '+266' },
  { flag: '🇱🇷', label: 'Liberia (+231)', code: '+231' },
  { flag: '🇱🇾', label: 'Libya (+218)', code: '+218' },
  { flag: '🇱🇮', label: 'Liechtenstein (+423)', code: '+423' },
  { flag: '🇱🇹', label: 'Lithuania (+370)', code: '+370' },
  { flag: '🇱🇺', label: 'Luxembourg (+352)', code: '+352' },
  { flag: '🇲🇴', label: 'Macao (+853)', code: '+853' },
  { flag: '🇲🇬', label: 'Madagascar (+261)', code: '+261' },
  { flag: '🇲🇼', label: 'Malawi (+265)', code: '+265' },
  { flag: '🇲🇾', label: 'Malaysia (+60)', code: '+60' },
  { flag: '🇲🇻', label: 'Maldives (+960)', code: '+960' },
  { flag: '🇲🇱', label: 'Mali (+223)', code: '+223' },
  { flag: '🇲🇹', label: 'Malta (+356)', code: '+356' },
  { flag: '🇲🇭', label: 'Marshall Islands (+692)', code: '+692' },
  { flag: '🇲🇶', label: 'Martinique (+596)', code: '+596' },
  { flag: '🇲🇷', label: 'Mauritania (+222)', code: '+222' },
  { flag: '🇲🇺', label: 'Mauritius (+230)', code: '+230' },
  { flag: '🇾🇹', label: 'Mayotte (+262)', code: '+262' },
  { flag: '🇲🇽', label: 'Mexico (+52)', code: '+52' },
  { flag: '🇫🇲', label: 'Micronesia (+691)', code: '+691' },
  { flag: '🇲🇩', label: 'Moldova (+373)', code: '+373' },
  { flag: '🇲🇨', label: 'Monaco (+377)', code: '+377' },
  { flag: '🇲🇳', label: 'Mongolia (+976)', code: '+976' },
  { flag: '🇲🇪', label: 'Montenegro (+382)', code: '+382' },
  { flag: '🇲🇸', label: 'Montserrat (+1-664)', code: '+1-664' },
  { flag: '🇲🇦', label: 'Morocco (+212)', code: '+212' },
  { flag: '🇲🇿', label: 'Mozambique (+258)', code: '+258' },
  { flag: '🇲🇲', label: 'Myanmar (+95)', code: '+95' },
  { flag: '🇳🇦', label: 'Namibia (+264)', code: '+264' },
  { flag: '🇳🇷', label: 'Nauru (+674)', code: '+674' },
  { flag: '🇳🇵', label: 'Nepal (+977)', code: '+977' },
  { flag: '🇳🇱', label: 'Netherlands (+31)', code: '+31' },
  { flag: '🇳🇨', label: 'New Caledonia (+687)', code: '+687' },
  { flag: '🇳🇿', label: 'New Zealand (+64)', code: '+64' },
  { flag: '🇳🇮', label: 'Nicaragua (+505)', code: '+505' },
  { flag: '🇳🇪', label: 'Niger (+227)', code: '+227' },
  { flag: '🇳🇬', label: 'Nigeria (+234)', code: '+234' },
  { flag: '🇳🇺', label: 'Niue (+683)', code: '+683' },
  { flag: '🇳🇫', label: 'Norfolk Island (+672)', code: '+672' },
  { flag: '🇲🇵', label: 'Northern Mariana Islands (+1-670)', code: '+1-670' },
  { flag: '🇳🇴', label: 'Norway (+47)', code: '+47' },
  { flag: '🇴🇲', label: 'Oman (+968)', code: '+968' },
  { flag: '🇵🇰', label: 'Pakistan (+92)', code: '+92' },
  { flag: '🇵🇼', label: 'Palau (+680)', code: '+680' },
  { flag: '🇵🇸', label: 'Palestine (+970)', code: '+970' },
  { flag: '🇵🇦', label: 'Panama (+507)', code: '+507' },
  { flag: '🇵🇬', label: 'Papua New Guinea (+675)', code: '+675' },
  { flag: '🇵🇾', label: 'Paraguay (+595)', code: '+595' },
  { flag: '🇵🇪', label: 'Peru (+51)', code: '+51' },
  { flag: '🇵🇭', label: 'Philippines (+63)', code: '+63' },
  { flag: '🇵🇳', label: 'Pitcairn Islands (+64)', code: '+64' },
  { flag: '🇵🇱', label: 'Poland (+48)', code: '+48' },
  { flag: '🇵🇹', label: 'Portugal (+351)', code: '+351' },
  { flag: '🇵🇷', label: 'Puerto Rico (+1-787, +1-939)', code: '+1-787' },
  { flag: '🇶🇦', label: 'Qatar (+974)', code: '+974' },
  { flag: '🇷🇴', label: 'Romania (+40)', code: '+40' },
  { flag: '🇷🇺', label: 'Russia (+7)', code: '+7' },
  { flag: '🇷🇼', label: 'Rwanda (+250)', code: '+250' },
  { flag: '🇷🇪', label: 'Réunion (+262)', code: '+262' },
  { flag: '🇼🇸', label: 'Samoa (+685)', code: '+685' },
  { flag: '🇸🇲', label: 'San Marino (+378)', code: '+378' },
  { flag: '🇸🇦', label: 'Saudi Arabia (+966)', code: '+966' },
  { flag: '🇸🇳', label: 'Senegal (+221)', code: '+221' },
  { flag: '🇷🇸', label: 'Serbia (+381)', code: '+381' },
  { flag: '🇸🇨', label: 'Seychelles (+248)', code: '+248' },
  { flag: '🇸🇱', label: 'Sierra Leone (+232)', code: '+232' },
  { flag: '🇸🇬', label: 'Singapore (+65)', code: '+65' },
  { flag: '🇸🇽', label: 'Sint Maarten (+1-721)', code: '+1-721' },
  { flag: '🇸🇰', label: 'Slovakia (+421)', code: '+421' },
  { flag: '🇸🇮', label: 'Slovenia (+386)', code: '+386' },
  { flag: '🇸🇧', label: 'Solomon Islands (+677)', code: '+677' },
  { flag: '🇸🇴', label: 'Somalia (+252)', code: '+252' },
  { flag: '🇿🇦', label: 'South Africa (+27)', code: '+27' },
  { flag: '🇰🇷', label: 'South Korea (+82)', code: '+82' },
  { flag: '🇸🇸', label: 'South Sudan (+211)', code: '+211' },
  { flag: '🇪🇸', label: 'Spain (+34)', code: '+34' },
  { flag: '🇱🇰', label: 'Sri Lanka (+94)', code: '+94' },
  { flag: '🇧🇱', label: 'Saint Barthélemy (+590)', code: '+590' },
  { flag: '🇸🇭', label: 'Saint Helena (+290)', code: '+290' },
  { flag: '🇰🇳', label: 'Saint Kitts and Nevis (+1-869)', code: '+1-869' },
  { flag: '🇱🇨', label: 'Saint Lucia (+1-758)', code: '+1-758' },
  { flag: '🇲🇫', label: 'Saint Martin (+590)', code: '+590' },
  { flag: '🇵🇲', label: 'Saint Pierre and Miquelon (+508)', code: '+508' },
  { flag: '🇻🇨', label: 'Saint Vincent and the Grenadines (+1-784)', code: '+1-784' },
  { flag: '🇸🇩', label: 'Sudan (+249)', code: '+249' },
  { flag: '🇸🇷', label: 'Suriname (+597)', code: '+597' },
  { flag: '🇸🇯', label: 'Svalbard and Jan Mayen (+47)', code: '+47' },
  { flag: '🇸🇿', label: 'Swaziland (+268)', code: '+268' },
  { flag: '🇸🇪', label: 'Sweden (+46)', code: '+46' },
  { flag: '🇨🇭', label: 'Switzerland (+41)', code: '+41' },
  { flag: '🇸🇾', label: 'Syria (+963)', code: '+963' },
  { flag: '🇹🇼', label: 'Taiwan (+886)', code: '+886' },
  { flag: '🇹🇯', label: 'Tajikistan (+992)', code: '+992' },
  { flag: '🇹🇿', label: 'Tanzania (+255)', code: '+255' },
  { flag: '🇹🇭', label: 'Thailand (+66)', code: '+66' },
  { flag: '🇹🇱', label: 'Timor-Leste (+670)', code: '+670' },
  { flag: '🇹🇬', label: 'Togo (+228)', code: '+228' },
  { flag: '🇹🇰', label: 'Tokelau (+690)', code: '+690' },
  { flag: '🇹🇴', label: 'Tonga (+676)', code: '+676' },
  { flag: '🇹🇹', label: 'Trinidad and Tobago (+1-868)', code: '+1-868' },
  { flag: '🇹🇳', label: 'Tunisia (+216)', code: '+216' },
  { flag: '🇹🇷', label: 'Turkey (+90)', code: '+90' },
  { flag: '🇹🇲', label: 'Turkmenistan (+993)', code: '+993' },
  { flag: '🇹🇨', label: 'Turks and Caicos Islands (+1-649)', code: '+1-649' },
  { flag: '🇹🇻', label: 'Tuvalu (+688)', code: '+688' },
  { flag: '🇺🇬', label: 'Uganda (+256)', code: '+256' },
  { flag: '🇺🇦', label: 'Ukraine (+380)', code: '+380' },
  { flag: '🇦🇪', label: 'United Arab Emirates (+971)', code: '+971' },
  { flag: '🇬🇧', label: 'United Kingdom (+44)', code: '+44' },
  { flag: '🇺🇸', label: 'United States (+1)', code: '+1' },
  { flag: '🇺🇾', label: 'Uruguay (+598)', code: '+598' },
  { flag: '🇺🇿', label: 'Uzbekistan (+998)', code: '+998' },
  { flag: '🇻🇺', label: 'Vanuatu (+678)', code: '+678' },
  { flag: '🇻🇦', label: 'Vatican City (+39)', code: '+39' },
  { flag: '🇻🇪', label: 'Venezuela (+58)', code: '+58' },
  { flag: '🇻🇳', label: 'Vietnam (+84)', code: '+84' },
  { flag: '🇼🇫', label: 'Wallis and Futuna (+681)', code: '+681' },
  { flag: '🇾🇪', label: 'Yemen (+967)', code: '+967' },
  { flag: '🇿🇲', label: 'Zambia (+260)', code: '+260' },
  { flag: '🇿🇼', label: 'Zimbabwe (+263)', code: '+263' },
]);

const resetUser = () => {
  form.value = {
    countryCode: '',
    firstname: '',
    lastname: '',
    gender: '',
    phone_number: '',
    address: '',
    country_code: '',
    birth_date: '',
    about: '',
  }
}

defineExpose({
  editDialog
})
</script>
