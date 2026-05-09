var yup = require('yup');

module.exports = {

	async validateInsert(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('Informe o nome.'),
				telefone: yup.string().required('Informe o telefone.'),
				categorias: yup.array().required('Informe a(s) categoria(s).')
			});

			await schema.validate(req.body.prestador, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
