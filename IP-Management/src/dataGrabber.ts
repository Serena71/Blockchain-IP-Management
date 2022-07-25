export async function grabData(method: string, body: object) {
  const axios = require('axios');
  if (method == 'get') {
    return axios
      .get('http://localhost:5050/checkStatus', { params: body })
      .then(async function (response: any) {
        return response?.data;
      })
      .catch(function (error: any) {
        console.log(error);
      });
  } else if (method == 'post') {
    return axios
      .post('http://localhost:5050/addLicense', body)
      .then(async function (response: any) {
        return response?.data;
      })
      .catch(function (error: any) {
        console.log(error);
      });
  }
}
