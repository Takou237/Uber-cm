const sdk = require('node-appwrite');

module.exports = async function (context) {
  // 1. Initialisation du SDK Appwrite
  const client = new sdk.Client()
    .setEndpoint('https://tor.cloud.appwrite.io/v1')
    .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY); // Ta clé API secrète

  const users = new sdk.Users(client);
  const databases = new sdk.Databases(client);

  // ID de ta base de données (vérifie bien cet ID dans ta console Appwrite)
  const DATABASE_ID = '695d1b430005eb249f4b'; 
  const COLLECTION_ID = 'profiles';

  // 2. Récupération des données envoyées par ton app Flutter
  if (!context.req.body) {
    return context.res.json({ error: 'Corps de la requête vide' }, 400);
  }

  // On essaie de parser le JSON envoyé par Flutter
  let payload;
  try {
    payload = typeof context.req.body === 'string' 
      ? JSON.parse(context.req.body) 
      : context.req.body;
  } catch (e) {
    return context.res.json({ error: 'JSON invalide' }, 400);
  }

  const { email, password, name, role, phone } = payload;

  try {
  // 3. Création de l'utilisateur dans Auth
    context.log(`Création de l'utilisateur : ${email}`);
    
    // On vérifie si le téléphone commence par +, sinon on ne l'envoie pas à users.create
    // car Appwrite lèvera une erreur.
    const validPhone = (phone && phone.startsWith('+')) ? phone : undefined;

    const user = await users.create(
      sdk.ID.unique(),
      email,
      validPhone, // Utilise le numéro validé ou undefined
      password,
      name
    );

    // 4. Création du profil dans la base de données
    context.log(`Création du profil pour l'id : ${user.$id}`);
    await databases.createDocument(
      DATABASE_ID,
      COLLECTION_ID,
      sdk.ID.unique(),
      {
        userId: user.$id,
        role: role || 'client',
        phone: phone || '',
        createdAt: new Date().toISOString()
      }
    );

    return context.res.json({
      success: true,
      message: 'Utilisateur et profil créés !',
      userId: user.$id
    });

  } catch (error) {
    context.error('Erreur lors de l\'inscription : ' + error.message);
    return context.res.json({
      success: false,
      error: error.message
    }, 400);
  }
};