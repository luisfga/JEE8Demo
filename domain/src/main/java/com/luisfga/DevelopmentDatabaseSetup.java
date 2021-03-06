package com.luisfga;

import com.luisfga.business.entities.AppRole;
import java.io.IOException;
import java.util.List;

import javax.annotation.Resource;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceUnit;
import javax.persistence.Query;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.NotSupportedException;
import javax.transaction.RollbackException;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.hsqldb.persist.HsqlProperties;
import org.hsqldb.server.ServerAcl;
import org.hsqldb.server.WebServer;

/* Usada apenas em desenvolvimento para checar/carregar o que for preciso no banco de dados */
@WebListener
public class DevelopmentDatabaseSetup implements ServletContextListener {

    Logger logger = LogManager.getLogger();
    
    @Resource
    private UserTransaction tx;

    @PersistenceUnit(unitName = "applicationJpaUnit")
    EntityManagerFactory emf;

    WebServer server;
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {

//        startHSQLDBServerMode();

        checkRequiredData();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
//        server.shutdown();
    }

    private void startHSQLDBServerMode() {
        try {
            System.out.println("Starting Database");
            HsqlProperties p = new HsqlProperties();
            p.setProperty("server.database.0", "file:../data/ShiroStrutsJEE8/shiro_struts_jee8");
            p.setProperty("server.dbname.0", "applicationDB");
            p.setProperty("server.port", "9001");
            server = new WebServer();
            server.setProperties(p);
            server.setLogWriter(null); // can use custom writer
            server.setErrWriter(null); // can use custom writer
            server.start();
        } catch (ServerAcl.AclFormatException | IOException ioex) {
            logger.error("Erro ao tentar iniciar o HSQLDB em modo SERVER", ioex);
        }
    }
    
    private void checkRequiredData() {
        logger.info("Checando dados necessários");

        try {

            tx.begin();
            
            EntityManager em = emf.createEntityManager();

            Query findBasicRole = em.createNamedQuery("AppRole.findRolesForNewUser");
            List<AppRole> roles = findBasicRole.getResultList(); //apenas faz a query pra ver se vai dar NoResultException

            if(!roles.isEmpty()){
                logger.info("Dados OK!");
            } else {
                logger.info("Dados não encontrados");
                //se não retornar nada precisamos incluir
                AppRole registeredUserRole = new AppRole();
                registeredUserRole.setRoleName("Normal User");

                em.persist(registeredUserRole);
                logger.info("Salvou: {0}", registeredUserRole);
            }

            tx.commit();

        } catch (IllegalStateException | SecurityException | NotSupportedException 
                | SystemException | RollbackException | HeuristicMixedException 
                | HeuristicRollbackException  ex) {
            logger.error(ex.getMessage());
            
        }
    }
}
