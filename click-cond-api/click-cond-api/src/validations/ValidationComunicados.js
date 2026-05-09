var yup = require('yup');

module.exports = {

	async validateInsertComunicado(req, res, next) {
		try {
			const schema = yup.object().shape({
				titulo: yup.string().required('Informe o título'),
				descricao: yup.string().required('Informe a descrição.'),              
			});

			await schema.validate(req.body.comunicado, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
