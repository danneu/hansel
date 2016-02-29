'use strict'

const fs = require('fs')

// TODO: enumerate all tags, this is incomplete
const tags = [
  'a',
  'abbr',
  'blockquote',
  'body',
  'br',
  'b',
  'button',
  'caption',
  'code',
  'div',
  'em',
  'form',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'head',
  'hr',
  'html',
  'img',
  'input',
  'link',
  'li',
  'meta',
  'option',
  'ol',
  'param',
  'p',
  'script',
  'select',
  'span',
  'strong',
  'style',
  'table',
  'td',
  'textarea',
  'th',
  'tbody',
  'thead',
  'tfoot',
  'title',
  'tr',
  'ul',
  'u'
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
  'keygen',
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
