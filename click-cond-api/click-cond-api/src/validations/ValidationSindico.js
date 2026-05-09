var yup = require('yup');

module.exports = {

	async validateLogin(req, res, next) {
		try {
			const schema = yup.object().shape({
				login: yup.string().required('Login inválido'),
				password: yup.string().min(6, 'A senha deve conter no mínimo 6 caracteres').required('A senha deve conter no mínimo 6 caracteres'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},

	async validateSignup(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('O campo do nome é obrigatório'),
				email: yup.string().email('E-mail inválido').required('E-mail inválido'),
				date_birth: yup.string().min(10, 'Data de Nascimento inválida').max(10, 'Data de Nascimento inválida'),
				password: yup.string().min(6, 'A senha deve conter no mínimo 6 caracteres').required('A senha deve conter no mínimo 6 caracteres'),
				phone: yup.string().required('Telefone inválido'),
				doc_identification: yup.string().required('Documento de Identificação Inválido'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += "• "+e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},

	async validateUpdate(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('O campo do nome é obrigatório'),
				email: yup.string().email('E-mail inválido').required('E-mail inválido'),
				date_birth: yup.string().min(10, 'Data de Nascimento inválida').max(10, 'Data de Nascimento inválida'),
				phone: yup.string().required('Telefone inválido'),
				doc_identification: yup.string().required('Documento de Identificação Inválido'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += "• "+e.message + '\n'; });
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
	
	async validateNewPassword(req, res, next) {
		try {
			const schema = yup.object().shape({
				newPassword: yup.string().min(6).required('A senha deve conter no mínimo 6 caracteres'),
				confirmPassword: yup.string().oneOf([yup.ref('newPassword'), null], 'A Senha não confere com o campo Confirmar Senha')
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
