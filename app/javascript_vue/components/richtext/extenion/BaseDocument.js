import { Node } from '@tiptap/core'

export const BaseDocument = Node.create({
  name: 'doc',
  topNode: true,
  content: 'block+',
});

export default BaseDocument