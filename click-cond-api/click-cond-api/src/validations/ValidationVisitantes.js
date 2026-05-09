var yup = require('yup');

module.exports = {

	async validateInsert(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('Informe o nome.'),
				doc_identificacao: yup.string().required('Informe o documento de identificação.'),
				data_inicio: yup.string().required('Informe a data de inicio da liberação.'),
				data_termino: yup.string().required('Informe a data de término da liberação.'),
				is_visitante: yup.bool().required('Informe se é Visitante ou Prestador.'),
				is_prestador: yup.bool().required('Informe se é Visitante ou Prestador.'),
				id_apartamento: yup.number().required('Informe o apartamento'),
			});

			await schema.validate(req.body.visitante, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
