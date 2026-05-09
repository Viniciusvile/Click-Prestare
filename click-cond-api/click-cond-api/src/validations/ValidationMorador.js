var yup = require('yup');

module.exports = {

	async validateInsert(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('Informe o nome.'),
				email: yup.string().required('Informe o email.'),
				data_nascimento: yup.string().required('Informe a data de nascimento.'),
				documento: yup.string().required('Informe o documento.'),
				telefone: yup.string().required('Informe o telefone.'),
				// tipo: yup.string().required('Informe o tipo Proprietário/Inquilino.'),
			});

			await schema.validate(req.body.morador, { abortEarly: false });
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
