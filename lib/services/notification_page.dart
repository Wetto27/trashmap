import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:trashmap/widgets/recyclers/custom_app_bar_return.dart';
import 'package:trashmap/services/notification_button.dart';
import 'package:trashmap/services/notification_services.dart';
import 'package:trashmap/widgets/recyclers/top_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarReturn(context, 'TRASHMAP'),
      backgroundColor: Colors.blue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.grey[200]!,
            ],
          )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const TopBar(title: 'Painel de notificações'),
            NotificationButton(
              text: "Notificação simples",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Dia de botar o lixo para fora",
                  body: "O motorista começou sua rota!",
                );
              }
            ),
            NotificationButton(
              text: "Notificação com sumário",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Titulo da notificação",
                  body: "Corpo da notificação",
                  summary: "Pequeno sumário da notificação",
                  notificationLayout: NotificationLayout.Inbox,
                );
              },
            ),
            NotificationButton(
              text: "Notificação com barra de progressão",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Titulo da notificação",
                  body: "Corpo da notificação",
                  summary: "Pequeno sumário da notificação",
                  notificationLayout: NotificationLayout.ProgressBar,
                );
              },
            ),
            NotificationButton(
            text: "Mensagem de notificação",
            onPressed: () async {
               await NotificationService.showNotification(
                  title: "Titulo da notificação",
                  body: "Corpo da notificação",
                  summary: "Pequeno sumário da notificação",
                  notificationLayout: NotificationLayout.Messaging,
               );
             },
            ),
            NotificationButton(
              text: "Notificação com imagem grande",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Titulo da notificação",
                  body: "Corpo da notificação",
                  summary: "Pequeno sumário da notificação",
                  notificationLayout: NotificationLayout.BigPicture,
                  bigPicture: 
                      "https://files.tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg",
                );
              },
            ),
            NotificationButton(
              text: "Botão de ação de notificação",
              onPressed: () async {
                 await NotificationService.showNotification(
                  title: "Titulo da notificação",
                  body: "Corpo da notificação",
                  payload: {
                   "navigate": "true",
                  },
                  actionButtons: [
                    NotificationActionButton(
                      key: 'check',
                      label: 'check it out',
                      actionType: ActionType.SilentAction,
                      color: Colors.green,
                    )
                  ]
                 );
              },
            ),
            NotificationButton(
              text: "Notificação agendada",
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Notificação agendada",
                  body: "Notificação enviada após 5 segundos",
                  scheduled: true,
                  interval: 5,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}