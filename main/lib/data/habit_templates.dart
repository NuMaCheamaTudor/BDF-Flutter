import '../models/habit.dart';

final Map<String, List<Habit>> habitTemplates = {
  'adhd': [
    Habit(id: '1', title: 'Pomodoro 25 min focus', description: 'Concentrează-te 25 min fără întreruperi'),
    Habit(id: '2', title: 'Scrie 3 taskuri mici', description: 'Ajută la organizarea gândurilor'),
    Habit(id: '3', title: 'Pauză activă la 2 ore', description: 'Ridică-te și mișcă-te puțin')
  ],
  'depresie': [
    Habit(id: '4', title: 'Ieși 10 minute afară', description: 'Aer curat și lumină naturală'),
    Habit(id: '5', title: 'Scrie 1 gând pozitiv', description: 'Focus pe lucruri bune'),
    Habit(id: '6', title: 'Bea un pahar cu apă', description: 'Hidratarea contează')
  ],
  'anxietate': [
    Habit(id: '7', title: 'Respirație 4-7-8', description: 'Exercițiu de calmare'),
    Habit(id: '8', title: 'Scrie ce te neliniștește', description: 'Descărcare emoțională'),
    Habit(id: '9', title: 'Mindfulness 5 min', description: 'Conectează-te cu prezentul')
  ],
};
