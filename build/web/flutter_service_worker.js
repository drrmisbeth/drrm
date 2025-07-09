'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "366d8df215b54e2cd96278172d5f6747",
".git/config": "1e5e7a2107c45c2e4667920c5aa27ccf",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "36465e5b9217ed287cac74a5ee2700c4",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "dcb11ada80af5c0494c6fe266505f499",
".git/logs/refs/heads/master": "944682d740ed42a6e6538104a0dcef7f",
".git/logs/refs/remotes/origin/master": "90c68d47685117676ac426c2f8428cb7",
".git/objects/01/d3da581b8255685780d80ab4a531a15d640074": "e204aa4d766ee3bbe0b162602aec6385",
".git/objects/03/0424d1d821691687596792eb0acfd2f8be798e": "7e791566825420c0f941df3060f6b91d",
".git/objects/03/112100ca6957c5159cacc8fafb990785bc42c5": "7f0b69b7efc9ce54dc97d1ec15e0abe9",
".git/objects/03/518b331377d8b61c4c3ceea74c9ff22d1b9e8b": "60446a2b261913172f8bc834fe6b83d7",
".git/objects/07/bda18450e0f1c14cf64343aef9161a6f865739": "bd277ffa42f63823e2e465ca4dc9ff63",
".git/objects/07/f7b0255b29361543df78cdf5906fe719eed7ff": "9d30e7daac141a39c288c661592b8bab",
".git/objects/08/0c9ee6eef2c4e6ebdd7e86142089dad796ecc9": "e0a0a248a5efc64813b947d54c355e76",
".git/objects/09/d2010f29802024499a79ed67bb22411acd1086": "c65d37447e356d484889fabd77d84c1d",
".git/objects/0f/3f00075be6903dc8c2c15a9a59e90d0bc1c0bd": "948019be9e8283151164053a696ece4e",
".git/objects/12/f58499211f8827c1ddf76be132479b7cf3efdb": "44f3c691708acc2878cb575d11f2415e",
".git/objects/13/4ff71eec24a48ee8a65e14a9b1a9d36bc25dcc": "f9dac7e41d4b55a6af3b12d7190a3f66",
".git/objects/14/84f7aca23568805b01001ff72de4beb24a835d": "8ec1c72709a796e1e5d878de6d38f3d3",
".git/objects/14/a268cd0933aa5d8d1052a353b5cf4a4f02bdbc": "3ea8594bfaa94c7fbcf1221155e229d8",
".git/objects/15/9165c18aa0efc572dca4b14fe52b069384c92c": "98ee67098c4bb0aa4e1d0a8c37b3cbca",
".git/objects/16/2f628ed1b627052a16134b7631f2873afb61fc": "4f67b64650b338402357ec6ffd23a7b5",
".git/objects/1a/01f110107f2cd1d435ff106979551ad219f1d0": "c0f726012b8dbc5cb1c3681970e84a0d",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/1f/04627acebca332d5c488e699302e9113ece445": "ef01e2e52218efd184433dd132308dcd",
".git/objects/21/43bf778465dca9912db6806b3a288d65c0f721": "97b941ab54cf1a490b5c30f07c50078f",
".git/objects/23/48062e04f9c32f06b4ddda872ae0e833a1ad2d": "15657dbcaf845e1549865abdd87cf9b5",
".git/objects/26/ae17b948326bf0d3b3d41c5e662f8b29f5eb7a": "dcc8015a8b6cde734996e64a4ee4a5df",
".git/objects/2c/d2a3a257938d9c36131ab67dce530fdd45988a": "aa32c5ad799d7baf719cdbd6f8363876",
".git/objects/2d/ba8fea76bb643162d8226dd8d9dfe15eb3f574": "49eafadb452dc9c85e608787a73da7f0",
".git/objects/2f/01b9fb4dc10b23de685926f696b471fadc14fb": "da684bf4164bd4d43d7385a047c09f39",
".git/objects/30/4a0b0287803b0276d38811aea9fd50677df7b3": "6810b633592b73c6287febba5deb4a08",
".git/objects/30/df5020d65f97dfae6172131538f9b772f23f85": "6f59a625cd5e006237f7ba930c8c640c",
".git/objects/32/0db2039fa49869c9b2f5089fc45cd4887f2d02": "f1d625403e95ed636322ae1038fb103b",
".git/objects/35/30562c65814bbcac383ff1157249f1906df3fb": "a1e70d0094f35e1d9ce0bbc707232269",
".git/objects/38/6df1fc680c04565ac085075bf75792d4983ef5": "5d18da0794763807bed6ff89d18efca6",
".git/objects/38/ef53b8f2abc929599cfc5cd7818c1596f5c8b8": "45744416896a1d8abd86d2b43339470a",
".git/objects/39/47be17dc5d549712a3e33d3eda4b7193f82f8d": "b2a11dc3b43a7b7a12f627df8922e3cb",
".git/objects/3a/2decddebbbf53803d58d37069b629443e1ec8b": "ee922ddeaae999f66ec4dd04c4798336",
".git/objects/3a/6b80f0565eb43310f2965101f63c0791f08575": "3b3bdb735c38ef937023622a935d6195",
".git/objects/3c/5ca9daad7fb5aef1163ff3d4e22f6777e6a415": "ba9486c0749eb8400401e065faec8509",
".git/objects/3c/96963a33b65fbfaf2b6388ecd45af329845484": "3367007d329c0a0c9204292e8654e4d4",
".git/objects/3e/9d86ea45b4e79cfd3ba41cd94147fac1561414": "77c50d4cbb386bbf031f6947835c9299",
".git/objects/40/13b5b63b40053b2178d8fcd7f014c09a07374b": "bd0e7937549003f398bae571a4a32732",
".git/objects/45/7e9580a64adceca99baeee08af3aac5ce3b57c": "9cbb5ca939922d4b9b8dc04fa2c94bec",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/47/15a5d1c851bc86935cb289af3a4193df428d3f": "33f66dd64a9a2b12886c4b24a2049de8",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/4e/ed4fc6a1b27febc5acdf01f8a95c636d15a4c3": "cd1e70dff9108dde91aeb65a63da2fde",
".git/objects/4f/45c68f7c7341e1d3ef463e2b159ad9219f725f": "8cf9ca3a2ce5c2d24445017591350782",
".git/objects/4f/eb331b2bf96143842d365dfa8b08d08382ece1": "a7b5d28060104418ebe71e29d2adbc05",
".git/objects/50/7e0ee39168a410b2b4291f0785548bd39352bd": "d52b36b3010c2bd7f58d9bc4f69ef0e0",
".git/objects/51/379037fe6bee92a66b643d514a70a70a2af9cf": "062e82fd4e61f98433234dea0993fd22",
".git/objects/52/b955ab332f48dfdcddb958e05e867a6012eb04": "58a86093159543e3beeae4a1386bfaf3",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/55/8aafd41a5ade4f83b929feb183fdb5f978a3aa": "550b2bfd611189fa7bee6ed14421db6a",
".git/objects/58/73ac95ef25c2d3e041be643ccf10aad80fdc47": "c166f90534683edd3c2eadbe48016b62",
".git/objects/59/101a5ab87a28f0e5a52fda901a14a5d476b23e": "fac362f10a5d97e671a467634e00d357",
".git/objects/59/208fcaf00fbc96b02eb29a1670793194a6bf29": "6c3ba5592319103eca57157b4e0ea445",
".git/objects/59/482b875cd3c8c562af8667d48c4fec87cb5371": "a3c082404aec977ab5b3d4ec39bb7028",
".git/objects/5b/e32f2637abae46db2cb470e0fdda021ee082ad": "482346750dad3a9536743fcdc1d98607",
".git/objects/5c/c3c758f1f899d3e5d95e31ac501f06fc022674": "dd73e4131295c462d019fcc7cc0a9734",
".git/objects/62/e3ba44c24ae750ca31d2210cb451ec2caccffe": "97dc9ae3d4bb0014d072c680ec8ba57a",
".git/objects/65/6011715a05374aef6da3af5f4df8d7b0c4d27f": "0ed3bf64174b6546fcd1ed525264e169",
".git/objects/68/4ab880332f505853ebd94a7e92790bad9921b2": "1cf8cbcc682be6c00959cdb73cff36b7",
".git/objects/68/90571b34feb53a49a73c87cddc6a809fcbe172": "7a654655f5f4759d0909c8d7b27cf2e6",
".git/objects/68/d174684ac197ea1b29f052905e795f7292a8bd": "179677e926c7dceccb4d95caccac56d2",
".git/objects/69/34244c2c14edd07b6794d59b8e76ef0075e933": "264448b3602a77594ee494ae7ea83514",
".git/objects/6a/731a5707928aba3bd9f34a20b634d22af47fef": "bb55a8b1875eeea35287ab5b410b7b52",
".git/objects/6b/6c3965c40193f6b534effee6426e7e49708a3c": "db916f539efc91d892e1598db7cfba0e",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6c/5dbda31c2e9390ffdedc238b6c2e4ed69a921c": "486e7062ceb8436d5c7755433451be0a",
".git/objects/6d/5af6df37b09889c06961f19f00cb36e50e33f2": "d56d535a941fecad39beb86938488bbe",
".git/objects/6d/ce57390e8645992d64f6f66b4bedb3477635bd": "7b027d94b8094e6e2a4ef0c629466ab6",
".git/objects/70/723caa1d0fab4890093d420add99a36bfa8ffe": "f65eaa2701bf81ccdf5bcc82b4c62ef0",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/73/5eb2a4f173beb9c874483bdb58fa7e58c9eeb1": "91cfea5ea60c01405acfd781d6becada",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/7f/f0951a8e23370d3e3f97bbf1d607ff72600b65": "0a9ac16ef6d6c60aa82ae15884f3b3e0",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/8e144d4c73e061e8bccc6e1630db5cdd5046fb": "a63424088ed42b17bc1e0a8db1f5e7b5",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8b/75ec8d0cebdb7ef81b8e76b352e87b7b4139d4": "7f239738ebb84bba9f6705adb31488f1",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/92/58a375cd9f1b907f2e821ce01f2f337379bd4c": "55447cd9acd0636543cfd00994258d42",
".git/objects/98/007d1aa29ffe474e0fd795fb3342a373136611": "d634e06088b95b119bdd747e9705e70e",
".git/objects/98/6a658a2e8f38586242b9e98c178b692c88bcf9": "811b88c3bf5d4457b404b7abe089016b",
".git/objects/98/dada8167dfe3a8088f06748e5f03c68211aa8f": "165ccfb0cce199eb2daabdbc64976fd2",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/9c/1ae086b2cc7e5e952d9482eaf876e36559faa0": "6cfc79dd1d5d4c94d69ffee698f0280f",
".git/objects/9e/57d8b383008847897c96ee51b4a457ad5df3d4": "98b53271dd669bbcfadc58c45c97b4cb",
".git/objects/a2/9021a7c5b4ec6b799bcb74f70c08a83752dc8f": "f340a114126aa886f7a7627f00e6187c",
".git/objects/a2/b93438c2dc8123efc581fdae0f5b9d789c5d27": "f3b4cac671946176fd66381ced0824b8",
".git/objects/a7/d829dc850fff44bc6701f09e2cbe27ef7901c2": "db011f07f0da6915b2fe66684dac5f76",
".git/objects/a8/6570250f8bb13930f6161116b154dd377cd431": "2b66f62413b5e1e9acc7ca8255fb8527",
".git/objects/b2/5672ee6dee3029802927b308a0991e0cddd629": "4bdd6c48977688fcd88de1f064f7d89e",
".git/objects/b2/a9c578b02cc302e8a8941eb9360a79a5c42aa8": "30dd85682e489813e5ab1ba1ff5b5a95",
".git/objects/b4/178573d796282a1f9a3e018399f799c397a72a": "c9cf59366f24972dc36c48ebc794d5e1",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/b9/f44f8f5b9787da231ccab73ae093c2d870a3bc": "58c74356aee6ba9d1162ce343b39bfc8",
".git/objects/bc/2de4f4816a09ee4d8c94316e2b46ee8f551c61": "8e658b0dd2a12c24508e31357e7f4f82",
".git/objects/c0/43276e7554c2aa53204055b18fbc9129ddde4b": "9918710d7f47bc711e046f720b215321",
".git/objects/c1/672b7d586bb20c026c402dc0a256ec8664fc80": "7a7479fc11832713e8ef48f59beeaf1d",
".git/objects/c2/5fb1b007868707ce39cdb216403bc3f9db03b1": "4b0bf4022fa64e62a665f81081ff547b",
".git/objects/c3/e08f6051f35482748eb87a5d6b2c06e17b963d": "912e6fc46177684c43e2bda30680abb2",
".git/objects/c5/96c799580277ffd30ba1070758092f09431261": "9b2fc6290afb365ee72cbb5db3512f4d",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/ca/28d7675113ec7591fc78cf27ec3439e896b71a": "22ee71b3edd0627056bef02aeb612752",
".git/objects/cb/167cc6e7ccb126ec5fcdfac3b1ff99f9284dbf": "87adfed0d827c35bf947cec6080523a7",
".git/objects/ce/40220772e68b8bf8334a6b05e4e4371c2a3d15": "9b71ad0b85b87d0db5a9008e1bf25e18",
".git/objects/ce/652df7218eda58f0ff1bc9b6b890a4e253a02e": "e7afe4c2687818e34536a3fe89bbb559",
".git/objects/d2/2ffdd04dc486c3ab5ef5ea80ec6471e702db70": "6189f548c93ff48dfc733fb5b9e9f7b7",
".git/objects/d2/6bd6048034c8a87923a11544d7c850871dd099": "786c2dd6b934abd748dbb06c7f7f86f1",
".git/objects/d3/b7e485282cec353d829ce2b24961d36a0fed47": "17fbf6e1fe474fcdc62fa90a1e3739c2",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d8/00da6e00f8ca363b09b12e03e481b4a56904ad": "ace7f283451d36b95a12cf2449374de6",
".git/objects/db/4a98c035b5081b86c22dd864587836d56a9c95": "2e83bbf6f936544914c813497fcaba27",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/dc/74bd35adee64eab861055897d296adeb1352b1": "4dc7d531d9fea204fbe1c5ae84304dd9",
".git/objects/dc/7cd17f011a29b344c9c89f7fc62146869842fd": "05b09061ea3aa6ee37423e1522d74e34",
".git/objects/df/964897ee3e3dd1ad0d35ba525ca345c45aa14b": "d5e681372cf1a4e182d3370ce60ea7ab",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/e1/a6807247d552e4ed1482e16198dc9167678e20": "48147963fe8adbf6fb45ee317a0ee158",
".git/objects/e8/d64e134c4da8720bad0181dc10d87de084dcdb": "592c7c3101cd5ccf5ecfd113cbcb3465",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/ea790edec30f880af153095a414ee3ba4d1298": "baf92d42ec502addf4b70f3a3c030501",
".git/objects/f3/09cea4e824199fce309fd32ffa67231203fea0": "c46aa62b9b8bc7c1ad8caed2d31a79ea",
".git/objects/f3/d1da0351bdae1c455b9fedb6c4041a212e4845": "58af3cccf18cf193963ede759172acd4",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f5/8784acffb87b4ccf25038165552e63f367571b": "09ab48cf43848890d9ab5c3de337cc8f",
".git/objects/f7/4a47d4fb40a4d01712202116df0df065e7916c": "711972fc91ddef31e9f74ab0154e9d76",
".git/objects/f8/21f9c4c0e8996a743de8ff4ac484d1ce274475": "03730680cebf972d53b4c35bcb27bd43",
".git/objects/f9/2ade120accc398b63256442fa3093b173435d6": "50b1541175a3904a702364edb9ad4c4a",
".git/objects/fb/306e29638636a017f7ff989f4782a417e3c0e9": "a780a12251250d2018f7c10c69e5024a",
".git/refs/heads/master": "82f6d6680c530431eee91574979c1d27",
".git/refs/remotes/origin/master": "82f6d6680c530431eee91574979c1d27",
"assets/AssetManifest.bin": "57ea15d78221ea7ace534adbbe6671db",
"assets/AssetManifest.bin.json": "e2d0c5c19a7ac8a7be4903b73c80b2e8",
"assets/AssetManifest.json": "8b4b210a8c1b25b7f8604e75994212c9",
"assets/assets/header.jpg": "56262d5144c501f004ec3ccb75461183",
"assets/assets/NATIONWIDE%2520SIMULTANEOUS%2520EARTHQUAKE%2520DRILL(Template%25203_School%2520Conso%2520for%2520SDO)1.csv": "1f8c23e5313df7ea9da730c5e7734851",
"assets/assets/templateexport.xlsx": "2f31995b55441fc356a64224e189194b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "5cceeab1c11cf2daae246d3bcffa9e01",
"assets/NOTICES": "ae2bb26874b24ca2457601c73044680a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"drrmlog.png": "66febfddd259224e6fa44e61d51c57c1",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "73e5f792c8000309d64fe2b3ccd95f27",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "9fe18aafd11beaf6c07a4e493f394de9",
"/": "9fe18aafd11beaf6c07a4e493f394de9",
"main.dart.js": "8df2f93df90e800bd12b39580623f7d7",
"manifest.json": "5b8bb574ce1ab074518c23bbad43e100",
"version.json": "65ca189e2ea9ea7c28812f54c5530b9b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
