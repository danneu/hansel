'use strict'

const maxArity = 20

for (var n = 1; n <= maxArity; n++) {
  console.log(template(n))
}

for (var n = 1; n <= maxArity; n++) {
  console.log(templateWithAttrs(n))
}

function template (arity) {
  return `
public convenience init (${args(arity)}) {
  self.init([:], [${array(arity)}])
}`
}

function templateWithAttrs (arity) {
  return `
public convenience init (_ attrs: Attrs, ${args(arity)}) {
  self.init(attrs, [${array(arity)}])
}`
}

function args (arity) {
  var output = ''
  for (var n = 1; n <= arity; n++) {
    if (n > 1) output += ', '
    output += `_ a${n}: HtmlConvertible`
  }
  return output
}

function array (arity) {
  var output = ''
  for (var n = 1; n <= arity; n++) {
    if (n > 1) output += ', '
    output += `a${n}`
  }
  return output
}


