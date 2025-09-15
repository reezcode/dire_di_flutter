import 'package:dire_di_flutter/dire_di.dart';

import '../services/user_service.dart';

@Controller()
class UserController {
  @Autowired()
  late UserService userService;

  void handleGetUser(String id) {
    print('UserController: Handling request for user $id');
    userService.getUserById(id);
  }
}
