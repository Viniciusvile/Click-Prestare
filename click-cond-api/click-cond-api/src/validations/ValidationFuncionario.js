var yup = require('yup');

module.exports = {

	async validateInsert(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('Informe o nome.'),
				documento: yup.string().required('Informe o documento.'),
				email: yup.string().required('Informe o e-mail.'),
				telefone: yup.string().required('Informe o telefone.'),
				funcao: yup.string().required('Informe a função.'),
				ch: yup.string().required('Informe a carga horária.'),
				senha: yup.string().required('Informe a senha.'),
			});

			await schema.validate(req.body.funcionario, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},

	async validateUpdateInfos(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('Informe o nome.'),
				documento: yup.string().required('Informe o documento.'),
				email: yup.string().required('Informe o e-mail.'),
				telefone: yup.string().required('Informe o telefone.'),
			});

			await schema.validate(req.body.funcionario, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},

	async validateRecovery(req, res, next) {
		try {
			const schema = yup.object().shape({
				email: yup.string().email('E-mail inválido').required('E-mail inválido'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
