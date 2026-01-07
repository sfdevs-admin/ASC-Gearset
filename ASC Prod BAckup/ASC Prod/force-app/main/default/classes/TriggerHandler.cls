/**
 * @description This class handles the trigger logic for Task.
 * @Author Atrium - Nipun Jain
 * @date Oct 2024
 */

public virtual class TriggerHandler {
    
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
    
    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    /**
     * @description Constructor
     */
    public TriggerHandler() {
        this.setTriggerContext();
    }
    
    /***************************************
* public instance methods
***************************************/
    
    /**
     * @description main method that will be called during execution
    */
    public void run() {
        
        if(!validateRun()) {
            return;
        }
        
        addToLoopCount();
        
        // dispatch to the correct handler method
        switch on this.context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }
    
    /**
     * @description Set the maximum number of times this trigger should run
     * @param max - the maximum number of times this trigger should run
    */
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }
    
    /**
     * @description Clear the maximum number of times this trigger should run
    */
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
    
    /***************************************
* public static methods
***************************************/
    
    /**
     * @description Bypass the specified handler
     * @param handlerName - the name of the handler to bypass
    */
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    /**
     * @description Clear the bypass for the specified handler
     * @param handlerName - the name of the handler to clear the bypass for
    */
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    /**
     * @description Check if the specified handler is bypassed
     * @param handlerName - the name of the handler to check
     * @return Boolean - true if the handler is bypassed, false otherwise
    */
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    /**
     * @description Clear all bypasses
    */
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }
    
    /***************************************
* private instancemethods
***************************************/
    
    @TestVisible
    /**
     * @description Set the trigger context
    */
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    /**
     * @description Set the trigger context
     * @param ctx - the context to set
     * @param testMode - true if in test mode, false otherwise
    */
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
    
        if (ctx != null) {
            switch on ctx {
                when 'before insert' {
                    this.context = TriggerContext.BEFORE_INSERT;
                }
                when 'before update' {
                    this.context = TriggerContext.BEFORE_UPDATE;
                }
                when 'before delete' {
                    this.context = TriggerContext.BEFORE_DELETE;
                }
                when 'after insert' {
                    this.context = TriggerContext.AFTER_INSERT;
                }
                when 'after update' {
                    this.context = TriggerContext.AFTER_UPDATE;
                }
                when 'after delete' {
                    this.context = TriggerContext.AFTER_DELETE;
                }
                when 'after undelete' {
                    this.context = TriggerContext.AFTER_UNDELETE;
                }
            }
        } else {
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    this.context = TriggerContext.BEFORE_INSERT;
                }
                when BEFORE_UPDATE {
                    this.context = TriggerContext.BEFORE_UPDATE;
                }
                when BEFORE_DELETE {
                    this.context = TriggerContext.BEFORE_DELETE;
                }
                when AFTER_INSERT {
                    this.context = TriggerContext.AFTER_INSERT;
                }
                when AFTER_UPDATE {
                    this.context = TriggerContext.AFTER_UPDATE;
                }
                when AFTER_DELETE {
                    this.context = TriggerContext.AFTER_DELETE;
                }
                when AFTER_UNDELETE {
                    this.context = TriggerContext.AFTER_UNDELETE;
                }
            }
        }
    }
      
    
    @TestVisible
    /**
     * @description increment the loop count
    */
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }
    
    @TestVisible
    /**
     * @description make sure this trigger should continue to run
     * @return Boolean - true if the run is valid, false otherwise
    */
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }
    
    @TestVisible
    /**
     * @description get the name of the handler
     * @return String - the name of the handler
    */
    private String getHandlerName() {
        return this.toString().substringBefore(':');
    }
    
    /***************************************
* context methods
***************************************/
    
    // context-specific methods for override
    @TestVisible
    /**
     * @description before insert context
    */
    protected virtual void beforeInsert(){
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE INSERT ***');
    }

    @TestVisible
    /**
     * @description before update context
    */
    protected virtual void beforeUpdate(){
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE UPDATE ***');
    }

    @TestVisible
    /**
     * @description before delete context
    */
    protected virtual void beforeDelete(){
        System.debug(LOGGINGLEVEL.INFO, '*** BEFORE DELETE ***');
    }

    @TestVisible
    /**
     * @description after insert context
    */
    protected virtual void afterInsert(){
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER INSERT ***');
    }
    
    @TestVisible
    /**
     * @description after update context
    */
    protected virtual void afterUpdate(){
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER UPDATE ***');
    }
    
    @TestVisible
    /**
     * @description after delete context
    */
    protected virtual void afterDelete(){
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER DELETE ***');
    }
    
    @TestVisible
    /**
     * @description after undelete context
    */
    protected virtual void afterUndelete(){
        System.debug(LOGGINGLEVEL.INFO, '*** AFTER UNDELETE ***');
    }
    
    /***************************************
* inner classes
***************************************/
    
    @TestVisible
    /**
     * @description inner class for managing the loop count per handler
     */
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        /**
         * @description Constructor
         */
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        /**
         * @description Constructor
         * @param max - the maximum number of times this trigger should run
         */
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        /**
         * @description increment the loop count
         * @return Boolean - true if the loop count has been exceeded, false otherwise
         */
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        /**
         * @description check if the loop count has been exceeded
         * @return Boolean - true if the loop count has been exceeded, false otherwise
         */
        public Boolean exceeded() {
            return this.max >= 0 && this.count > this.max;
        }
        
        /**
         * @description get the maximum number of times this trigger should run
         * @return Integer - the maximum number of times this trigger should run
         */
        public Integer getMax() {
            return this.max;
        }
        
        /**
         * @description get the current count
         * @return Integer - the current count
         */
        public Integer getCount() {
            return this.count;
        }
        
        /**
         * @description set the maximum number of times this trigger should run
         * @param max - the maximum number of times this trigger should run
         */
        public void setMax(Integer max) {
            this.max = max;
        }
    }
    
    // possible trigger contexts
    @TestVisible
    /**
     * @description enum for trigger context
     */
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    // exception class
    public class TriggerHandlerException extends Exception {}
    
}