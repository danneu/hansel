'use strict'

const tags = [
  'a',
  'abbr',
  'address',
  'area',
  'article',
  'audio',
  'base',
  'blockquote',
  'body',
  'b',
  'bdi',
  'bdo',
  'br',
  'button',
  'canvas',
  'caption',
  'cite',
  'code',
  'col',
  'colgroup',
  'data',
  'datalist',
  'del',
  'dfn',
  'dd',
  'details',
  'dialog',
  'div',
  'dl',
  'dt',
  'element',
  'em',
  'embed',
  'fieldset',
  'figcaption',
  'figure',
  'footer',
  'form',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'head',
  'header',
  'hgroup',
  'hr',
  'html',
  'i',
  'img',
  'input',
  'ins',
  'kbd',
  'label',
  'legend',
  'link',
  'li',
  'map',
  'mark',
  'main',
  'menu',
  'menuitem',
  'meta',
  'meter',
  'nav',
  'noscript',
  'object',
  'optgroup',
  'option',
  'output',
  'ol',
  'p',
  'param',
  'pre',
  'progress',
  'q',
  's',
  'script',
  'section',
  'select',
  'small',
  'source',
  'span',
  'strong',
  'style',
  'sub',
  'summary',
  'sup',
  'table',
  'td',
  'template',
  'textarea',
  'th',
  'tbody',
  'thead',
  'tfoot',
  'title',
  'tr',
  'track',
  'ul',
  'u',
  'video',
  'wbr'
]

// https://www.w3.org/TR/html-markup/syntax.html#syntax-elements
// TODO: merge lists together
const voidTags = [
  'area',
  'base',
  'br',
  'col',
  'command',
  'embed',
  'hr',
  'img',
  'input',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr'
]

function capitalize (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

function voidTemplate () {
  return `
  override var void: Bool {
    get { return true } set { self.void = newValue } 
  }`
}

function template (tag) {
  return `
class ${tag}: Element {
  override var tagName: String {
    get { return "${tag}" } set { self.tagName = newValue }
  }${voidTags.indexOf(tag) !== -1 ? voidTemplate() : ''}
}`
}

tags.forEach((tag) => {
  console.log(template(tag))
})
