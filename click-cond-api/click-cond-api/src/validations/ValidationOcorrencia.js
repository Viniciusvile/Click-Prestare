var yup = require('yup');

module.exports = {

	async validateInsert(req, res, next) {
		try {
			if(req.body.ocorrencia.isResposta != null && req.body.ocorrencia.isResposta == true){
				const schema = yup.object().shape({
					status: yup.string().required('Selecione o status da ocorrência.'),
				});
				await schema.validate(req.body.ocorrencia, { abortEarly: false });
			} else {
				const schema = yup.object().shape({
					tipo: yup.string().required('Selecione o tipo da ocorrência.'),
					descricao: yup.string().required('Informe o descritivo.'),
				});
				await schema.validate(req.body.ocorrencia, { abortEarly: false });
			}
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
