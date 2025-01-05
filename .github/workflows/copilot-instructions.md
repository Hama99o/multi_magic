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
