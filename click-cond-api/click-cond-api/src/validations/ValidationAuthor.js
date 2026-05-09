var yup = require('yup');

module.exports = {
	async validateSignup(req, res, next) {
		try {
			const schema = yup.object().shape({
				affiliation: yup.object().shape({
					affiliationId: yup.string(),
				}),
				personalData: yup.object().shape({
					name: yup.string().matches(/^[A-Za-z ]*$/, 'Nome inválido').required('O campo do nome é obrigatório'),
					lastName: yup.string().matches(/^[A-Za-z ]*$/, 'Sobrenome inválido').required('O campo do sobrenome é obrigatório'),
					phone: yup.string().max(15).required('Telefone inválido'),
					email: yup.string().email('E-mail inválido').required('E-mail inválido'),
					doc: yup.string().max(18).required('Documento inválido'),
					docType: yup.string().oneOf(['CPF', 'CNPJ'], 'O documento informado deve ser CPF ou CNPJ',).required('O tipo do documento é obrigatório'),
					password: yup.string().min(6).required('A senha deve conter no mínimo 6 caracteres'),
					confirmPassword: yup.string().oneOf([yup.ref('password'), null], 'A Senha não confere com o campo Confirmar Senha')
				}),
				address: yup.object().shape({
					cep: yup.string().matches(/^[0-9\-]*$/, 'CEP Inválido').required('O CEP é obrigatório'),
					street: yup.string().matches(/^[A-Za-z .]*$/, 'Rua inválido').required('O campo da rua é obrigatório'),
					number: yup.number().required('Número inválido'),
					complement: yup.string(),
					neighborhood: yup.string().required('Documento inválido'),
					city: yup.string().required('Cidade inválida'),
					uf: yup.string().min(2).required('UF inválido'),
					country: yup.string().required('País inválido'),
				}),
				bank: yup.object().shape({
					bankNumber: yup.string().min(1).required('Informe o banco'),
					ag: yup.string().required('Informe a agência bancária'),
					agDigit: yup.string(),
					cc: yup.string().required('Informe a conta corrente'),
					ccDigit: yup.string().required('Informe o dígito da conta corrente'),
				}),
				photos: yup.object().shape({
					photoProfile: yup.string().required('Foto do perfil é obrigatória'),
					docFront: yup.string().required('Foto da frente do documento é obrigatória'),
					docBack: yup.string().required('Foto da frente do verso é obrigatória'),
					docProfile: yup.string().required('Foto segurando o documento é obrigatória'),
				}),
				payment: yup.object().shape({
					// planIds: yup.array.min(1, 'Selecione ao menos um plano'),
					cardHolderName: yup.string().matches(/^[A-Za-z ]*$/, 'Nome do cartão de crédito inválido').required('O nome do cartão de crédito inválido'),
					cardNumber: yup.number().min(16).required('Número do cartão de crédito inválido'),
					cardExpirationDate: yup.string().min(5).max(5).required('Data de vencimento do cartão de crédito inválido'),
					cardCvv: yup.string().min(3).max(4).required('CVV do cartão de crédito inválido'),
					parcelas: yup.number().min(1).max(12).required('Número de parcelas inválido'),
				})
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}

	},
	async validateLogin(req, res, next) {
		try {
			const schema = yup.object().shape({
				email: yup.string().email('E-mail inválido').required('E-mail inválido'),
				password: yup.string().min(6).required('A senha deve conter no mínimo 6 caracteres'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
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
			error.inner.forEach(e => { message += e.message + '\n'; });
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
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}

	},
	async validatePost(req, res, next) {
		try {
			const schema = yup.object().shape({
				title: yup.string().min(6).required('O título deve conter no mínimo 6 caracteres'),
				image: yup.string().required('Imagem inválida'),
				shortDescription: yup.string().min(20, 'A descrição curta deve conter no mínimo 20 caracteres').required('A descrição curta é obrigatória'),
				description: yup.string().min(20, 'A descrição deve conter no mínimo 20 caracteres').required('A descrição é obrigatória'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}

	},
	async validatePost(req, res, next) {
		try {
			const schema = yup.object().shape({
				title: yup.string().min(6).required('O título deve conter no mínimo 6 caracteres'),
				image: yup.string().required('Imagem inválida'),
				shortDescription: yup.string().min(20, 'A descrição curta deve conter no mínimo 20 caracteres').required('A descrição curta é obrigatória'),
				description: yup.string().min(20, 'A descrição deve conter no mínimo 20 caracteres').required('A descrição é obrigatória'),
			});

			await schema.validate(req.body, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}

	},
};
