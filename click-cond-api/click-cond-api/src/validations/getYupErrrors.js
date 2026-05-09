const { ValidationError } = require('yup');

module.exports = (errors) => {
  console.log(errors)
  if (!errors instanceof ValidationError) throw new Error('This is not a yup error');
  const arr = {};
  errors.inner.forEach(e => {
    arr[e.path] = e.message;
  });
  return arr;
}