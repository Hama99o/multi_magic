# Vuejs or inside app/javascript folder

## Introduction

when ever you generate api file you need to check model exist or not for that api file and if not exist then you need to generate model file.

add good comments to each time if needed but not too much

model will be generated in app/javascript/models folder.
and value will be camelcase of model name. which will convert to snakecase from data ruby on rails api send to it

in api file we use
import { http } from '@/services/http.service';

```javascript
// bad
import axios from 'axios';

// good
import { http } from '@/services/http.service';
```

````

# typescript
do not use type any

```typescript
// bad
const user: any = { name: 'John Doe' };

// good
const user
```

# ruby

use symbols instead of strings

```ruby
# bad
'hello'

# good
:hello
````

use class name .name

```ruby
# bad
"User"

# good
User.name
```

# ruby on rails

add good comments to each time if needed but not too much

when we create model it should check if policy exist or not and if not exist then it should generate policy file. same for serializer and service file.

remeber each app has it own tables

ex:
SafezoneApp is and app:

- SafezoneApp::PaymentCard
- SafezoneApp::Password

only user

first you need to add migration file, thank you have to add mode file for table

model can be with app or without app
ex:

class CreateNoteAppNotes < ActiveRecord::Migration[7.0]
def change
create_table :note_app_notes do |t|
t.references :owner, foreign_key: { to_table: :users }
t.integer :status, default: 0, null: false
t.jsonb :data
t.string :title
t.text :description
t.datetime :deleted_at

      t.timestamps
    end

end
end

module NoteApp
def self.table*name_prefix
"note_app*"
end
end

class NoteApp::Note < ApplicationRecord
end

you can add factory also:
spec/factories/note_app/notes.rb

FactoryBot.define do
factory :note, class: 'NoteApp::Note' do
title { Faker::Book.title }
description { Faker::Lorem.paragraph }
status { :published }
owner factory: %i[user]
end
end

when every you add a table for model file you can check if the app exist you need to add add model in app folder

same for controller and routes
you will need to add controller with serilizer and policy
we use blueprinter serializer
ex:
app/serializers/note_app/note_serializer.rb

class NoteApp::NoteSerializer < ApplicationSerializer
identifier :id

fields :title, :description, :data, :status, :created_at, :deleted_at, :updated_at

end

you will need to add policy same like model folder should be app name and then it will be model policy
app/serializers/application_serializer.rb
use can add

class ApplicationSerializer < Blueprinter::Base
view :note_rights do
include_view :online
end
view :online do
fields :username
end
association :user, blueprint: UserSerializer, view: :public
end

app/policies/note_app/note_policy.rb

class NoteApp::NotePolicy < ApplicationPolicy
class Scope < Scope # NOTE: Be explicit about which records you allow access to!
def resolve
scope.all
end
end

def show?
user == record.owner || record.shared_with_users.where(id: user.id).present?
end

def create?
user.present?
end

def update?
return true if user == record.owner
role = record.shares.find_by(shared_with_user: user).role
['contributor', 'administrator'].include?(role)
end

def destroy?
return true if user == record.owner
role = record.shares.find_by(shared_with_user: user).role
'administrator' == role
end

def share_with_user_toggle?
destroy?
end

def restore?
destroy?
end

def destroy_permanently?
destroy?
end
end

in controller for index

you will use paginate_render and for show edit delete or other single data render you will use render_with_serializer and for error you will use render_unprocessable_entity all methods are in ApplicationController:
methods:

def paginate_render(serializer_const, list, page: 1, per_page: 10, root: list&.table_name, meta: {}, extra: {})
@pagy, @records = pagy(list, items: per_page)

    render json: serializer_const.render(
      @records,
      root:,
      meta: {
        **meta,
        pagy: pagy_metadata(@pagy),
        total_count: list.count
      },
      **extra
    ),
      status: :ok

end

def render_with_serializer(
serializer_const,
entity,
opt={}
)
root = opt.delete(:root) || entity&.class&.table_name&.singularize
view = opt.delete(:view) || nil
status = opt.delete(:status) || :ok

    render json: serializer_const.render_as_hash(
      entity,
      view: view,
      root: root,
      **opt
    ),
          status: status

end

def render_unprocessable_entity(entity)
render json: { message: entity.is_a?(Array) ? entity : entity.errors.full_messages },
status: :unprocessable_entity
end

ex:

def destroy
authorize @plan

    if @plan.destroy
      render_blue(
        Okr::PlanSerializer,
        @plan,
        view: :show,
        status: :ok
      )
    else
      render_unprocessable_entity(@plan)
    end

end

def index
@plans = policy_scope(Okr::Plan)

    paginate_blue(
      Okr::PlanSerializer,
      @plans.order(created_at: :desc),
      extra: { view: :index }
    )

end

class Api::V1::NoteApp::NotesController < ApplicationController

before_action :note, only: [:show, :update, :destroy, :restore, :destroy_permanently, :reminder]
end

same for the route you will need it

now we jump to front vuejs side:

for each controller, you will need to add api file in
ex:
app/javascript/apis/safezone_app/payment_card.api.ts
you will use import { http } from '@/services/http.service'; and model in api methods

import { http } from '@/services/http.service';
import {
PaymentCard,
transformPaymentCard,
transformPaymentCardToSnakeCase,
} from '@/models/payment_card.model';

const API_URL = '/api/v1/safezone_app/payment_cards';

// Fetch all payment cards with optional search parameter
export const fetchPaymentCards = async (search = '', page = 1): Promise<PaymentCard[]> => {
const response = await http.get(API_URL, { params: { search, page } });
response.data.payment_cards = response.data.payment_cards.map(transformPaymentCard);
return response.data;
};

// Fetch a single payment card by ID
export const fetchPaymentCard = async (id: number): Promise<PaymentCard> => {
const response = await http.get(`${API_URL}/${id}`);
return transformPaymentCard(response.data);
};

// Create a new payment card
export const createPaymentCard = async (
paymentCard: Partial<PaymentCard>,
): Promise<PaymentCard> => {
const response = await http.post(API_URL, transformPaymentCardToSnakeCase(paymentCard));
return transformPaymentCard(response.data);
};

// Update an existing payment card by ID
export const updatePaymentCard = async (
id: number,
paymentCard: Partial<PaymentCard>,
): Promise<PaymentCard> => {
const response = await http.put(`${API_URL}/${id}`, transformPaymentCardToSnakeCase(paymentCard));
return transformPaymentCard(response.data);
};

// Delete a payment card by ID
export const deletePaymentCard = async (id: number): Promise<void> => {
await http.delete(`${API_URL}/${id}`);
};

you need to add model file like this:
you will need to add snake_case and camelCase method in back we use snake_case and in front camelCase and add all attributes serializer send
app/javascript/models/payment_card.model.ts

export interface PaymentCard {
id: number;
name: string;
cardType: number;
cardNumber: string;
cvv: string;
expiryDate: string;
status: number;
note: string;
code: string;
ownerId: number;
createdAt: string;
updatedAt: string;
}

// Convert snake_case keys from Rails API to camelCase keys for the frontend
export const transformPaymentCard = (data: any): PaymentCard => {
return {
id: data.id,
name: data.name,
cardType: data.card_type,
cardNumber: data.card_number,
cvv: data.cvv,
expiryDate: data.expiry_date,
status: data.status,
note: data.note,
code: data.code,
ownerId: data.owner_id,
createdAt: data.created_at,
updatedAt: data.updated_at,
};
};

// Convert camelCase keys from frontend to snake_case keys for Rails API
export const transformPaymentCardToSnakeCase = (data: Partial<PaymentCard>): any => {
return {
id: data.id,
name: data.name,
card_type: data.cardType,
card_number: data.cardNumber,
cvv: data.cvv,
expiry_date: data.expiryDate,
status: data.status,
note: data.note,
code: data.code,
owner_id: data.ownerId,
created_at: data.createdAt,
updated_at: data.updatedAt,
};
};

you need to add store also :
you will use all method of api in it you will add pagination attributes and
same style as exemple:

import { defineStore } from 'pinia';
import {
fetchPaymentCards,
fetchPaymentCard,
createPaymentCard,
updatePaymentCard,
deletePaymentCard,
} from '@/apis/safezone_app/payment_card.api';
import { PaymentCard } from '@/models/payment_card.model';

export const usePaymentCardStore = defineStore({
id: 'payment-card-store',
state: () => ({
paymentCards: [] as PaymentCard[],
newPaymentCard: {
id: null as number | null,
name: '',
cardType: 'credit_card',
cardNumber: '',
cvv: '',
expiryDate: '',
status: 0,
note: '',
code: '',
ownerId: 0,
createdAt: '',
updatedAt: '',
} as Partial<PaymentCard>,
pagination: {},
search: '',
page: 1,
totalPages: 0,
loading: false,
error: null as string | null,
}),
getters: {
/**
_ Get a payment card by ID.
_/
getPaymentCardById: (state) => (id: number) =>
state.paymentCards.find((paymentCard) => paymentCard.id === id),
},
actions: {
/**
_ Fetch all payment cards and store them in the state.
_/
async fetchPaymentCards() {
this.loading = true;
this.error = null;
try {
const res = await fetchPaymentCards(this.search, this.page);
this.paymentCards = res.payment_cards;
this.page = res.meta.pagy.page
this.totalPages = res.meta.pagy.pages
this.pagination = {
current_page: res.meta.pagy.page,
total_pages: res.meta.pagy.pages,
total_items: res.meta.total_count,
};
} catch (error: unknown) {
this.error = (error as Error).message || 'Failed to fetch payment cards.';
} finally {
this.loading = false;
}
},

    /**
     * Fetch more payment cards for infinite scroll.
     */
    async fetchMorePaymentCards() {
      const res = await fetchPaymentCards(this.search, this.page);
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res.payment_cards;
    },

    /**
     * Fetch a single payment card by ID.
     */
    async fetchPaymentCard(id: number) {
      this.loading = true;
      this.error = null;
      try {
        const paymentCard = await fetchPaymentCard(id);
        return paymentCard;
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to fetch payment card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Create a new payment card entry.
     * @param data - New payment card data
     */
    async createPaymentCard(data: Partial<PaymentCard>) {
      this.loading = true;
      this.error = null;
      try {
        await createPaymentCard(data);
        await this.fetchPaymentCards();
        this.newPaymentCard = {
          id: null,
          name: '',
          cardType: 'credit_card',
          cardNumber: '',
          cvv: '',
          expiryDate: '',
          status: 0,
          note: '',
          code: '',
          ownerId: 0,
          createdAt: '',
          updatedAt: '',
        };
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to create payment card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Update an existing payment card entry by ID.
     * @param id - Payment card ID
     * @param data - Updated payment card data
     */
    async updatePaymentCard(id: number, data: Partial<PaymentCard>) {
      this.loading = true;
      this.error = null;
      try {
        const updatedCard = await updatePaymentCard(id, data);
        const index = this.paymentCards.findIndex((paymentCard) => paymentCard.id === id);
        if (index !== -1) {
          this.paymentCards[index] = updatedCard;
        }
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to update payment card.';
      } finally {
        this.loading = false;
      }
    },

    /**
     * Delete a payment card entry by ID.
     * @param id - Payment card ID
     */
    async deletePaymentCard(id: number) {
      this.loading = true;
      this.error = null;
      this.page = 1;
      try {
        await deletePaymentCard(id);
        await this.fetchPaymentCards();
      } catch (error: unknown) {
        this.error = (error as Error).message || 'Failed to delete payment card.';
      } finally {
        this.loading = false;
      }
    },

},
});

remember file the file exists you can overwrite the file but do not skip the process
each time i want to add a table you will do all this process and it should be respected the same as i share example i don't want other style i want same style.
